# Windows-app-remover

"I have a vision of creating a USB-based tool that automatically launches when plugged into a computer, allowing the user to choose exactly which built-in Windows apps should be uninstalled.

The goal is to make Windows refurbishment and deployment faster, cleaner, and more user-controlled — without breaking system stability.

This project is a step toward that vision, and community feedback and contributions are very welcome to help bring it to completion. - Murdervan"


A PowerShell-based Windows 10 & 11 built-in app removal tool designed for PC refurbishment, deployment, and clean system setups.

This project aims to reliably and safely remove unwanted built-in Windows applications, including AppX and provisioned packages, with logging, menu selection, and OneDrive full uninstall support.

⚠️ This project is a work in progress. Community help is strongly encouraged.

🔧 Project Goals

The goal of this repository is to create a clean, stable, and reliable Windows app removal script that:

Removes all listed built-in apps 100%, if technically possible

Handles AppX + Provisioned packages correctly

Avoids system breakage, errors, or partial removals

Works consistently across Windows 10 and Windows 11

Can be safely used for refurbishment and redeployment

If something cannot be removed due to Microsoft restrictions, the script should:

Detect it correctly

Log it clearly

Fail gracefully (no crashes, no broken state)

📌 Current Features

✅ Admin privilege check

✅ AppX + Provisioned package removal

✅ Full OneDrive uninstall (process, setup, leftovers)

✅ Menu-driven selection (single app or remove all)

✅ Logging with timestamps

✅ USB / portable execution support

🚧 Known Challenges

Some Windows apps are:

System-locked

Reinstalled automatically by Windows

Protected by dependencies or servicing stack rules

Examples:

Get Help

Certain system frameworks

Region or OEM-specific packages

We are looking for clean, correct solutions — not hacks that break Windows updates or system integrity.

🤝 Call for Help (Contributors Wanted)

This is where YOU come in.

I am actively looking for help with:

🧹 Code cleanup and refactoring

🧠 Better detection logic for installed vs provisioned apps

🪟 Windows 10 vs Windows 11 edge cases

📦 Apps that fail to uninstall or reinstall themselves

🛡️ Safe handling of protected/system apps

📝 Documentation improvements

If you know:

PowerShell best practices

Windows internals

AppX / provisioning behavior

Enterprise deployment or MDT / Intune scenarios

👉 Your input is highly appreciated.

Even small improvements, comments, or app removal confirmations help.

❗ Important Disclaimer

This script:

Is provided as-is

Makes system-level changes

Should be tested in VMs or test machines first

Use at your own risk.

📂 Repository

GitHub: https://github.com/Murdervan/Windows-app-remover

🧠 Philosophy

This project values:

Clean code

Predictable behavior

Transparency over silent failures

Community-driven improvement

The goal is not to "force-remove" everything at all costs — but to remove everything that can be removed, correctly.

📬 Contact / Contributions

Pull requests: Welcome

Issues: Encouraged

Suggestions: Please share

Let’s make Windows cleanup actually clean.

— Murdervan - AI TEXT! danish here 
