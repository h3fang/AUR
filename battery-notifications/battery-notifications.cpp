#include <chrono>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

#include <fmt/format.h>
#include <libnotify/notify.h>

using namespace std;

const string sys_path = "/sys/class/power_supply/{}/{}";
const string appname = "Battery Notifications";

const int THRESHOLD_HIGH = 85;
const int THRESHOLD_LOW = 40;
const int THRESHOLD_CRITICAL = 20;

enum class BatteyState { Unknown, Low, Critical, High, Normal };

void notify(int battery_level, const string &msg, NotifyUrgency urgency) {
    string body = fmt::format("Battery level: {}%", battery_level);

    if (msg != "" && notify_init(appname.data())) {
        NotifyNotification *notification = notify_notification_new(msg.data(), body.data(), NULL);
        notify_notification_set_urgency(notification, urgency);
        notify_notification_set_timeout(notification, NOTIFY_EXPIRES_NEVER);
        notify_notification_show(notification, NULL);
        g_object_unref(notification);
        notify_uninit();
    }
}

int main(int argc, char const *argv[]) {
    char *intvl = getenv("INTERVAL");
    const int interval = intvl ? stoi(intvl) : 30;
    char *bat = getenv("BAT_NAME");
    const string battery_name = bat ? bat : "BAT0";

    ifstream status_file(fmt::format(sys_path, battery_name, "status"));
    ifstream capacity_file(fmt::format(sys_path, battery_name, "capacity"));
    ifstream current_file(fmt::format(sys_path, battery_name, "current_now"));
    ifstream charge_now_file(fmt::format(sys_path, battery_name, "charge_now"));
    ifstream charge_full_file(fmt::format(sys_path, battery_name, "charge_full"));

    BatteyState state = BatteyState::Normal;

    setbuf(stdout, NULL);

    while (true) {
        string battery_state_str = "UNKNOWN";
        int battery_level = -1;

        status_file.clear(); status_file.seekg(0);
        capacity_file.clear(); capacity_file.seekg(0);

        status_file >> battery_state_str;
        capacity_file >> battery_level;

        string time_to_go, output;

        if (battery_state_str == "Discharging" || battery_state_str == "Charging") {
            int current = -1, charge_now = 1, charge_full = 2;
            current_file.clear(); current_file.seekg(0); current_file >> current;
            charge_now_file.clear(); charge_now_file.seekg(0); charge_now_file >> charge_now;
            charge_full_file.clear(); charge_full_file.seekg(0); charge_full_file >> charge_full;
            float t = battery_state_str == "Charging" ? float(charge_full-charge_now)/current : float(charge_now)/current;
            time_to_go = fmt::format("{}:{}", int(t), int((t-int(t))*60));
        }

        if (battery_state_str == "Discharging") {
            output = fmt::format(" {}% {}\n", battery_level, time_to_go);
            if (battery_level <= THRESHOLD_CRITICAL) {
                if (state != BatteyState::Critical) {
                    state = BatteyState::Critical;
                    notify(battery_level, "Battery is critically low", NOTIFY_URGENCY_CRITICAL);
                }
            }
            else if (battery_level <= THRESHOLD_LOW) {
                if (state != BatteyState::Low) {
                    state = BatteyState::Low;
                    notify(battery_level, "Battery is low", NOTIFY_URGENCY_NORMAL);
                }
            }
            else if (battery_level >= THRESHOLD_HIGH && state != BatteyState::High) {
                if (state != BatteyState::High) {
                    state = BatteyState::High;
                    notify(battery_level, "Battery is high", NOTIFY_URGENCY_NORMAL);
                }
            }
            else {
                state = BatteyState::Normal;
            }
        }
        else if (battery_state_str == "Charging") {
            state = BatteyState::Normal;
            output = fmt::format(" {}% {}\n", battery_level, time_to_go);
        }
        else {
            state = BatteyState::Normal;
            output = fmt::format(" {}%\n", battery_level);
        }

        // cout << output;

        this_thread::sleep_for(chrono::seconds(interval));
    }
    return 0;
}
