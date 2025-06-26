#include "../headers/wifi.hpp"
#include <cstring>

extern "C" {
#include "esp_log.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "nvs_flash.h"
}

namespace esperto {

static const char* TAG = "WiFi";

WiFi::WiFi() 
    : m_mode(Mode::Station), m_status(Status::Disconnected), m_netifSta(nullptr), 
      m_netifAp(nullptr), m_initialized(false) {
    
    // Initialize NVS if not already done
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
}

WiFi::~WiFi() {
    end();
}

bool WiFi::equals(const Object& other) const {
    auto* o = dynamic_cast<const WiFi*>(&other);
    return o && o->m_ssid == m_ssid;
}

bool WiFi::begin(Mode mode) {
    m_mode = mode;
    
    if (m_initialized) {
        return true;
    }

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    if (!initializeNetif()) {
        return false;
    }

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifiEventHandler, this));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &ipEventHandler, this));

    // Set WiFi mode
    wifi_mode_t wifiMode;
    switch (m_mode) {
        case Mode::Station:
            wifiMode = WIFI_MODE_STA;
            break;
        case Mode::AccessPoint:
            wifiMode = WIFI_MODE_AP;
            break;
        case Mode::StationAP:
            wifiMode = WIFI_MODE_APSTA;
            break;
    }
    
    ESP_ERROR_CHECK(esp_wifi_set_mode(wifiMode));
    ESP_ERROR_CHECK(esp_wifi_start());

    m_initialized = true;
    return true;
}

void WiFi::end() {
    if (!m_initialized) {
        return;
    }

    esp_wifi_stop();
    esp_wifi_deinit();
    
    esp_event_handler_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifiEventHandler);
    esp_event_handler_unregister(IP_EVENT, IP_EVENT_STA_GOT_IP, &ipEventHandler);
    
    cleanupNetif();
    
    m_initialized = false;
    m_status = Status::Disconnected;
}

bool WiFi::beginStation(const esperto::string& ssid, const esperto::string& password) {
    m_ssid = ssid;
    m_password = password;
    
    if (!begin(Mode::Station)) {
        return false;
    }

    wifi_config_t wifiConfig = {};
    strncpy((char*)wifiConfig.sta.ssid, ssid.c_str(), sizeof(wifiConfig.sta.ssid) - 1);
    strncpy((char*)wifiConfig.sta.password, password.c_str(), sizeof(wifiConfig.sta.password) - 1);
    
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifiConfig));
    
    return connect();
}

bool WiFi::connect() {
    if (m_mode == Mode::AccessPoint) {
        return false;
    }
    
    m_status = Status::Connecting;
    esp_err_t result = esp_wifi_connect();
    return result == ESP_OK;
}

bool WiFi::disconnect() {
    if (m_mode == Mode::AccessPoint) {
        return false;
    }
    
    esp_err_t result = esp_wifi_disconnect();
    if (result == ESP_OK) {
        m_status = Status::Disconnected;
        return true;
    }
    return false;
}

bool WiFi::reconnect() {
    disconnect();
    vTaskDelay(pdMS_TO_TICKS(100));
    return connect();
}

bool WiFi::beginAccessPoint(const esperto::string& ssid, const esperto::string& password, 
                           uint8_t channel, uint8_t maxConnections) {
    m_ssid = ssid;
    m_password = password;
    
    if (!begin(Mode::AccessPoint)) {
        return false;
    }

    wifi_config_t wifiConfig = {};
    strncpy((char*)wifiConfig.ap.ssid, ssid.c_str(), sizeof(wifiConfig.ap.ssid) - 1);
    wifiConfig.ap.ssid_len = ssid.length();
    
    if (!password.empty()) {
        strncpy((char*)wifiConfig.ap.password, password.c_str(), sizeof(wifiConfig.ap.password) - 1);
        wifiConfig.ap.authmode = WIFI_AUTH_WPA_WPA2_PSK;
    } else {
        wifiConfig.ap.authmode = WIFI_AUTH_OPEN;
    }
    
    wifiConfig.ap.channel = channel;
    wifiConfig.ap.max_connection = maxConnections;

    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &wifiConfig));
    
    m_status = Status::APStarted;
    return true;
}

bool WiFi::stopAccessPoint() {
    if (m_mode != Mode::AccessPoint && m_mode != Mode::StationAP) {
        return false;
    }
    
    // For AP mode, stopping is handled by end()
    end();
    return true;
}

WiFi::Status WiFi::getStatus() const {
    return m_status;
}

WiFi::Mode WiFi::getMode() const {
    return m_mode;
}

esperto::string WiFi::getSSID() const {
    return m_ssid;
}

esperto::string WiFi::getIPAddress() const {
    if (!m_initialized) {
        return "";
    }
    
    esp_netif_t* netif = (m_mode == Mode::AccessPoint) ? m_netifAp : m_netifSta;
    if (!netif) {
        return "";
    }
    
    esp_netif_ip_info_t ipInfo;
    if (esp_netif_get_ip_info(netif, &ipInfo) == ESP_OK) {
        char ipStr[16];
        snprintf(ipStr, sizeof(ipStr), IPSTR, IP2STR(&ipInfo.ip));
        return esperto::string(ipStr);
    }
    
    return "";
}

esperto::string WiFi::getMACAddress() const {
    uint8_t mac[6];
    wifi_interface_t interface = (m_mode == Mode::AccessPoint) ? WIFI_IF_AP : WIFI_IF_STA;
    
    if (esp_wifi_get_mac(interface, mac) == ESP_OK) {
        char macStr[18];
        snprintf(macStr, sizeof(macStr), "%02X:%02X:%02X:%02X:%02X:%02X",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
        return esperto::string(macStr);
    }
    
    return "";
}

int32_t WiFi::getRSSI() const {
    if (m_mode == Mode::AccessPoint || !isConnected()) {
        return 0;
    }
    
    wifi_ap_record_t apInfo;
    if (esp_wifi_sta_get_ap_info(&apInfo) == ESP_OK) {
        return apInfo.rssi;
    }
    
    return 0;
}

void WiFi::setEventCallback(EventCallback callback) {
    m_eventCallback = callback;
}

bool WiFi::isConnected() const {
    return m_status == Status::Connected;
}

bool WiFi::isAPActive() const {
    return m_status == Status::APStarted;
}

void WiFi::printInfo() const {
    printf("WiFi Status: ");
    switch (m_status) {
        case Status::Disconnected: printf("Disconnected\n"); break;
        case Status::Connecting: printf("Connecting\n"); break;
        case Status::Connected: printf("Connected\n"); break;
        case Status::APStarted: printf("AP Started\n"); break;
        case Status::Failed: printf("Failed\n"); break;
    }
    
    printf("SSID: %s\n", m_ssid.c_str());
    printf("IP Address: %s\n", getIPAddress().c_str());
    printf("MAC Address: %s\n", getMACAddress().c_str());
    
    if (m_mode == Mode::Station && isConnected()) {
        printf("RSSI: %ld dBm\n", getRSSI());
    }
}

bool WiFi::initializeNetif() {
    if (m_mode == Mode::Station || m_mode == Mode::StationAP) {
        m_netifSta = esp_netif_create_default_wifi_sta();
        if (!m_netifSta) {
            return false;
        }
    }
    
    if (m_mode == Mode::AccessPoint || m_mode == Mode::StationAP) {
        m_netifAp = esp_netif_create_default_wifi_ap();
        if (!m_netifAp) {
            return false;
        }
    }
    
    return true;
}

void WiFi::cleanupNetif() {
    if (m_netifSta) {
        esp_netif_destroy_default_wifi(m_netifSta);
        m_netifSta = nullptr;
    }
    
    if (m_netifAp) {
        esp_netif_destroy_default_wifi(m_netifAp);
        m_netifAp = nullptr;
    }
}

void WiFi::wifiEventHandler(void* arg, esp_event_base_t eventBase, 
                           int32_t eventId, void* eventData) {
    WiFi* wifi = static_cast<WiFi*>(arg);
    wifi->handleEvent(eventBase, eventId, eventData);
}

void WiFi::ipEventHandler(void* arg, esp_event_base_t eventBase, 
                         int32_t eventId, void* eventData) {
    WiFi* wifi = static_cast<WiFi*>(arg);
    wifi->handleEvent(eventBase, eventId, eventData);
}

void WiFi::handleEvent(esp_event_base_t eventBase, int32_t eventId, void* eventData) {
    if (eventBase == WIFI_EVENT) {
        switch (eventId) {
            case WIFI_EVENT_STA_START:
                ESP_LOGI(TAG, "WiFi station started");
                break;
            case WIFI_EVENT_STA_CONNECTED:
                ESP_LOGI(TAG, "Connected to WiFi");
                break;
            case WIFI_EVENT_STA_DISCONNECTED:
                ESP_LOGI(TAG, "Disconnected from WiFi");
                m_status = Status::Disconnected;
                if (m_eventCallback) {
                    m_eventCallback(m_status, "Disconnected");
                }
                break;
            case WIFI_EVENT_AP_START:
                ESP_LOGI(TAG, "WiFi AP started");
                m_status = Status::APStarted;
                if (m_eventCallback) {
                    m_eventCallback(m_status, "AP Started");
                }
                break;
        }
    } else if (eventBase == IP_EVENT) {
        switch (eventId) {
            case IP_EVENT_STA_GOT_IP:
                ESP_LOGI(TAG, "Got IP address");
                m_status = Status::Connected;
                if (m_eventCallback) {
                    m_eventCallback(m_status, "Connected with IP: " + getIPAddress());
                }
                break;
        }
    }
}

}