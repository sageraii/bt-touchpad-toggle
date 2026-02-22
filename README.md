# bt-touchpad-toggle

블루투스 마우스 연결 시 터치패드를 자동으로 끄고, 해제 시 다시 켜는 Linux 유틸리티입니다.

> Auto-disable touchpad when a Bluetooth mouse connects, re-enable when it disconnects.

## 요구사항 / Requirements

- Linux with GNOME desktop
- systemd (user session)
- `bluetoothctl`, `gdbus`, `gsettings`

## 설치 / Install

```bash
git clone https://github.com/sageraii/bt-touchpad-toggle.git
cd bt-touchpad-toggle
bash install.sh
```

## 수동 설치 / Manual Install

```bash
# 스크립트 복사
install -Dm755 touchpad-bt-toggle.sh ~/.local/bin/touchpad-bt-toggle.sh

# 서비스 파일 복사
install -Dm644 touchpad-bt-toggle.service ~/.config/systemd/user/touchpad-bt-toggle.service

# 서비스 활성화
systemctl --user daemon-reload
systemctl --user enable --now touchpad-bt-toggle.service
```

## 제거 / Uninstall

```bash
bash uninstall.sh
```

## 동작 원리 / How It Works

1. `bluetoothctl devices`로 페어링된 장치 목록을 조회합니다.
2. 각 장치의 `Icon: input-mouse` 속성으로 마우스를 구분합니다.
3. `gdbus monitor`로 블루투스 연결/해제 이벤트를 실시간 감시합니다.
4. 마우스가 연결되면 `gsettings`로 터치패드를 끄고, 해제되면 다시 켭니다.

---

1. Lists paired devices via `bluetoothctl devices`.
2. Identifies mice by the `Icon: input-mouse` property.
3. Monitors Bluetooth connect/disconnect events with `gdbus monitor`.
4. Disables the touchpad via `gsettings` on mouse connect, re-enables on disconnect.

## 상태 확인 / Check Status

```bash
systemctl --user status touchpad-bt-toggle
journalctl --user -u touchpad-bt-toggle -f
```

## 트러블슈팅 / Troubleshooting

### 서비스가 시작되지 않는 경우

```bash
# 로그 확인
journalctl --user -u touchpad-bt-toggle --no-pager -n 50

# 스크립트 직접 실행하여 에러 확인
~/.local/bin/touchpad-bt-toggle.sh
```

### 터치패드가 토글되지 않는 경우

```bash
# 블루투스 마우스가 페어링되어 있는지 확인
bluetoothctl devices

# 마우스 아이콘 속성 확인
bluetoothctl info <MAC_ADDRESS> | grep Icon
```

### DBUS_SESSION_BUS_ADDRESS 오류

Wayland/GNOME 세션에서 `gsettings`가 동작하려면 사용자 세션 버스가 필요합니다.
서비스가 사용자 세션(`systemctl --user`)으로 실행되고 있는지 확인하세요.

## License

[MIT](LICENSE)
