# ALBU BANK — CC:Tweaked 1.16.5

A simple central banking network for Minecraft 1.16.5 with CC:Tweaked.

## Files

- `installer.lua` — interactive installer for the current bank components.
- `bank_computer.lua` — central bank operator computer.
- `bank_server.lua` — central server. Handles accounts, cards, transfers, terminals and transaction logs.
- `bank_server_v2.lua` — compatible server version with the same transfer API, including ATM transfers.
- `atm.lua` — ATM. Reads an ALBU card from a disk drive and supports card information, balance, transactions and account-to-account transfers.
- `store_terminal.lua` — shop terminal.
- `lib/bank_client.lua` — shared modem client library used by ATM, bank computer and store terminal.

## Installer

Put `installer.lua` on a CC:Tweaked computer and run:

```text
installer
```

Choices:

```text
1. ATM
2. Bank Computer + Server
3. Bank Server
4. Store Terminal
5. Full Bank Package
6. Exit
```

The installer downloads the current files from this repository and creates `/lib` automatically when needed. It also removes the obsolete V2 copies from an installed computer so the machine does not accidentally run mismatched component versions.

The computer must have the CC:Tweaked HTTP API enabled because the installer downloads files over HTTPS from GitHub.

## Network

Every ALBU machine needs a modem. All components use modem port `4200`.

The bank server is the source of truth. ATMs and store terminals never edit account files directly.

## ATM transfers

ATM transfers use the network action:

```text
transfer
```

The ATM sends `card_id`, `pin`, `destination_account_id`, `amount` and `description` to the server. The server authenticates the card, validates both accounts and balances, moves the money, and writes a transaction record for both accounts.

After entering the transfer information, choose `Y` at the final confirmation. A successful transfer displays the transaction ID, recipient and remaining balance.

## Data layout on the bank computer

The first server start creates:

```text
/albu_bank/
  accounts/
    ACC-000001.dat
  cards/
    CARD-000001.dat
  terminals/
    TERM-000001.dat
  logs/
    ACC-000001.log
  next_account.txt
  next_card.txt
  next_terminal.txt
```

## Card format

An ALBU card is a writable floppy disk. The bank computer writes `/albu_card.dat` to the card. The physical card contains the card ID and account ID. The PIN is stored on the bank server's protected card record.

## Important

The bank server must stay online for ATMs and store terminals to work. When updating the system, restart the running server program so the computer loads the new Lua source.

The current implementation is designed for a trusted Minecraft RP environment. The server validates card operations, but the modem protocol is not cryptographically encrypted.
