import pytest

pytest_plugins = ["pytest_embedded"]

@pytest.mark.esp32
def test_restart_countdown():
    output = []
    def fake_printf(fmt, *args):
        output.append(fmt % args if args else fmt)
    for i in range(10, -1, -1):
        fake_printf("Restarting in %d seconds...\n", i)
    assert output[0] == "Restarting in 10 seconds...\n"
    assert output[-1] == "Restarting in 0 seconds...\n"
    assert len(output) == 11


@pytest.mark.esp32
def test_chip_info_print():
    CONFIG_IDF_TARGET = "ESP32"
    class ChipInfo:
        cores = 2
        features = 0b11
    chip_info = ChipInfo()
    major_rev = 1
    minor_rev = 0
    result = f"This is {CONFIG_IDF_TARGET} chip with {chip_info.cores} CPU core(s), WiFi/BT/BLE, "
    result += f"silicon revision v{major_rev}.{minor_rev}, "
    assert "ESP32 chip with 2 CPU core(s)" in result
    assert "/BT" in result and "/BLE" in result
    assert "silicon revision v1.0" in result


@pytest.mark.esp32
def test_flash_size_print():
    flash_size = 4 * 1024 * 1024
    class ChipInfo:
        features = 0b01
    chip_info = ChipInfo()
    flash_type = "embedded" if (chip_info.features & 0b01) else "external"
    result = f"{int(flash_size / (1024 * 1024))}MB {flash_type} flash\n"
    assert result == "4MB embedded flash\n"
