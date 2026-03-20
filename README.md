# Windows Integrity and Repair Utility

Batch script for checking Windows system integrity, servicing health, update components, drivers, and repair options.

## Functions

- **Quick integrity scan**  
  Shows OS details, update services, device problems, and disk usage.

- **SFC /scannow**  
  Scans and repairs protected Windows system files.

- **SFC Verify Only**  
  Checks protected system files without attempting repairs.

- **DISM CheckHealth**  
  Performs a quick component store corruption check.

- **DISM ScanHealth**  
  Performs a deeper scan for component store corruption.

- **DISM RestoreHealth**  
  Repairs component store corruption using Windows servicing.

- **Analyze Component Store**  
  Reviews WinSxS/component store health and cleanup recommendations.

- **Windows Update component check**  
  Reviews update-related services, SoftwareDistribution, catroot2, hotfixes, and related event log entries.

- **Driver and device checks**  
  Lists current device problems, installed drivers, and PnP drivers.

- **Disk and file system checks**  
  Shows disk usage and runs `chkdsk C: /scan`.

- **CBS / DISM / Windows Update event review**  
  Lists relevant servicing and update-related error events and log file paths.

- **Recommended standard repair**  
  Runs:
  - `DISM /CheckHealth`
  - `DISM /ScanHealth`
  - `DISM /RestoreHealth`
  - `SFC /scannow`

- **Report generation**  
  Creates a TXT report in:
  `Desktop\IntegrityReports`

## Notes

- Most repair actions require **administrator rights**.
- `SFC`, `DISM`, and `CHKDSK` can take significant time depending on system condition.
- Key logs:
  - `C:\Windows\Logs\CBS\CBS.log`
  - `C:\Windows\Logs\DISM\dism.log`
