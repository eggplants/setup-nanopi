# My setup for NanoPi R6S

## Environment

- Machine: [NanoPi R6S](https://www.friendlyelec.com/index.php?route=product/product&product_id=289)
- Tuner: [PX-W3U4](https://plex-net.co.jp/itemreco/px-w3u4/) (`/dev/px4video{0..3}`)
- Card reader: [SCR3310 v2.0](https://www.ntt.com/business/services/application/authentication/jpki/download10.html)
- OS: [rk3568-sd-debian-bookworm-core-6.1-arm64-20250811.img](https://drive.google.com/file/d/1hA3pUcZzdfSN1htq-3Nxn5ECr0EA1sa6/view?usp=drive_link) (Debian 12 / Linux 6.1, aarch64)

## Run

Connect a display and keyboard, log in as `pi`, and create your user:

```bash
sudo useradd -m -G "$(id -Gn pi | tr ' ' '\n' | grep -vx pi | paste -sd,)" eggplants
sudo passwd eggplants
```

Log in as `eggplants`, then:

```bash
curl -fsSL https://raw.githubusercontent.com/eggplants/setup-nanopi/main/bootstrap.sh | bash
sudo reboot

mise bootstrap
```

## Update

```bash
mise bootstrap --dry-run
mise bootstrap
mise bootstrap --update
mise bootstrap status
```

## Tasks

```bash
mise run tv:playlist
rm -rf ~/.config/mise/compose/scanned && mise bootstrap
```

## Check

- mirakc: `http://npi01.<tailnet>.ts.net:40772/api/version`
- EPGStation: `http://npi01.<tailnet>.ts.net:8888/#/`
- KonomiTV: `https://<tailscale-ip-with-dashes>.local.konomi.tv:7000/tv/`
- Grafana: `http://npi01.<tailnet>.ts.net:3000`

## Family

- [eggplants/setup-macos.sh](https://github.com/eggplants/setup-macos.sh)
- [eggplants/setup-termux.sh](https://github.com/eggplants/setup-termux.sh)
- [eggplants/setup-ubuntu.sh](https://github.com/eggplants/setup-ubuntu.sh)
- [eggplants/setup-nanopi](https://github.com/eggplants/setup-nanopi) <- here
- [eggplants/SetupWindows.ps1](https://github.com/eggplants/SetupWindows.ps1)
