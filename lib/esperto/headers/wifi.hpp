#pragma once

#include "object.hpp"
#include "types.hpp"
#include <functional>

extern "C" {
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_netif.h"
}

namespace esperto {

class WiFi : public Object {
public:
    enum class Mode {
        Station,      // Client mode
        AccessPoint,  // AP mode
        StationAP     // Both modes
    };

    enum class Status {
        Disconnected,
        Connecting,
        Connected,
        APStarted,
        Failed
    };

    using EventCallback = std::function<void(Status status, const esperto::string& info)>;

    WiFi();
    ~WiFi() override;

    // Object interface
    bool equals(const Object& other) const override;

    // WiFi Station (Client) methods
    bool beginStation(const esperto::string& ssid, const esperto::string& password);
    bool connect();
    bool disconnect();
    bool reconnect();

    // WiFi Access Point methods
    bool beginAccessPoint(const esperto::string& ssid, const esperto::string& password = "", 
                         uint8_t channel = 1, uint8_t maxConnections = 4);
    bool stopAccessPoint();

    // General methods
    bool begin(Mode mode);
    void end();
    Status getStatus() const;
    Mode getMode() const;
    
    // Network info
    esperto::string getSSID() const;
    esperto::string getIPAddress() const;
    esperto::string getMACAddress() const;
    int32_t getRSSI() const;
    
    // Event handling
    void setEventCallback(EventCallback callback);
    
    // Utility methods
    bool isConnected() const;
    bool isAPActive() const;
    void printInfo() const;

private:
    Mode m_mode;
    Status m_status;
    esperto::string m_ssid;
    esperto::string m_password;
    EventCallback m_eventCallback;
    esp_netif_t* m_netifSta;
    esp_netif_t* m_netifAp;
    bool m_initialized;

    // Static event handlers
    static void wifiEventHandler(void* arg, esp_event_base_t eventBase, 
                                int32_t eventId, void* eventData);
    static void ipEventHandler(void* arg, esp_event_base_t eventBase, 
                              int32_t eventId, void* eventData);

    // Helper methods
    bool initializeNetif();
    void cleanupNetif();
    void handleEvent(esp_event_base_t eventBase, int32_t eventId, void* eventData);
    Status convertWifiStatus() const;
};

} // namespace esperto