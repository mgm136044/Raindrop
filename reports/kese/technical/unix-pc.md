# RainDrop macOS - CII Unix/PC Audit (macOS Adapted)

**Date**: 2026-04-11  
**Target**: macOS 26.4.1 (Build 25E253) - Development Machine  
**Hostname**: mingyeongmin's Mac  

---

## Account Management (계정 관리)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| U-01 | Remote root login restriction | **Adequate** | `PermitRootLogin` is commented out (default: `prohibit-password`). Root password login is disabled. |
| U-02 | Password policy | **Adequate** | System password policy is configured (XML plist returned by `pwpolicy -getaccountpolicies`). |
| U-12 | Session timeout (TMOUT) | **Partial** | `$TMOUT` is not set. Terminal sessions do not auto-expire. Recommendation: Set `export TMOUT=3600` in shell profile for idle timeout. |
| U-14 | PATH integrity | **Adequate** | No double colons (`::`) or trailing colons (`:`) in `$PATH`. No current directory (`.`) in PATH. |

---

## File and Directory Management (파일 및 디렉터리 관리)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| U-16 | /etc/passwd permissions | **Adequate** | `-rw-r--r-- root wheel` (644). Only root can write. |
| U-23 | SUID files | **Adequate** | No SUID files found in `/usr/local`. |
| U-25 | World-writable files in project | **Adequate** | No world-writable files found in the project directory. |

---

## Network and Service Security (네트워크 및 서비스 보안)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| U-28 | Firewall status | **Adequate** | macOS Application Firewall is enabled (`State = 1`). |
| U-60 | SSH version | **Adequate** | OpenSSH 10.2p1 with LibreSSL 3.3.6. Current and patched version. |

---

## Logging and Patch Management (로깅 및 패치 관리)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| U-62 | Syslog configuration | **Adequate** | `/etc/syslog.conf` exists. macOS uses Unified Logging (os_log) as primary logging system, which is active by default. |
| U-67 | OS patch level | **Adequate** | macOS 26.4.1 - current release. Up to date. |

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| **Critical** | 0 | - |
| **High** | 0 | - |
| **Medium** | 1 | U-12 (no session timeout) |
| **Low** | 0 | - |
| **Adequate** | 10 | All other items |

**Total findings: 1 (0 Critical, 0 High, 1 Medium, 0 Low)**
