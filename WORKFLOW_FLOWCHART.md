# Development Workflow Flowchart

## 🗺️ Quick Decision Tree

This flowchart helps you quickly decide which validation tool to use based on your current situation.

```
                          📝 Making Code Changes?
                                    │
                                    ▼
                      ┌─────────────────────────────┐
                      │     What type of change?    │
                      └─────────────┬───────────────┘
                                    │
                 ┌──────────────────┼──────────────────┐
                 ▼                  ▼                  ▼
        🔧 Small Change    📝 Medium Change    🏗️ Major Change
        (1-5 min work)     (15-30 min work)   (1+ hour work)
                 │                  │                  │
                 ▼                  ▼                  ▼
        ./scripts/quick_    ./scripts/pre_    ./scripts/simulate_
        check.sh           commit_check.sh   ci.sh
        (10 seconds)       (30 seconds)      (60 seconds)
```

---

## 🔄 Complete Development Flow

```
┌─────────────────┐
│  Start Coding   │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐      ❌ Issues Found
│  Write Code     │◄─────────────────────┐
└─────────┬───────┘                      │
          │                              │
          ▼                              │
┌─────────────────┐                      │
│ Quick Check     │                      │
│ ./scripts/      │                      │
│ quick_check.sh  │──────────────────────┤
└─────────┬───────┘                      │
          │ ✅ Pass                      │
          ▼                              │
┌─────────────────┐                      │
│ Ready to        │                      │
│ Commit?         │                      │
└─────┬─────┬─────┘                      │
      │     │                            │
   No │     │ Yes                        │
      │     ▼                            │
      │ ┌─────────────────┐              │
      │ │ Pre-Commit      │              │
      │ │ Check           │              │
      │ │ ./scripts/      │              │
      │ │ pre_commit_     │              │
      │ │ check.sh        │──────────────┤
      │ └─────────┬───────┘              │
      │           │ ✅ Pass              │
      │           ▼                      │
      │ ┌─────────────────┐              │
      │ │ git commit      │              │
      │ └─────────┬───────┘              │
      │           │                      │
      │           ▼                      │
      │ ┌─────────────────┐              │
      │ │ Ready to        │              │
      │ │ Push?           │              │
      │ └─────┬─────┬─────┘              │
      │       │     │                    │
      │    No │     │ Yes                │
      ▼       │     ▼                    │
┌─────────────┐     ┌─────────────────┐  │
│ Continue    │     │ CI Simulation   │  │
│ Development │     │ ./scripts/      │  │
└─────────────┘     │ simulate_ci.sh  │──┤
                    └─────────┬───────┘  │
                              │ ✅ Pass  │
                              ▼          │
                    ┌─────────────────┐  │
                    │ git push        │  │
                    └─────────┬───────┘  │
                              │          │
                              ▼          │
                    ┌─────────────────┐  │
                    │ Monitor CI      │  │
                    │ gh run watch    │  │
                    │ or              │  │
                    │ ./scripts/      │  │
                    │ watch_ci.sh     │  │
                    └─────────┬───────┘  │
                              │          │
                              ▼          │
                    ┌─────────────────┐  │
                    │ CI Success?     │  │
                    └─────┬─────┬─────┘  │
                          │     │        │
                       No │     │ Yes    │
                          │     ▼        │
                          │ ┌─────────┐  │
                          │ │ Done!   │  │
                          │ └─────────┘  │
                          │              │
                          ▼              │
                    ┌─────────────────┐  │
                    │ Check Logs      │  │
                    │ gh run view     │  │
                    │ --log-failed    │  │
                    └─────────┬───────┘  │
                              │          │
                              ▼          │
                    ┌─────────────────┐  │
                    │ Fix Issues      │──┘
                    │ See             │
                    │ TROUBLESHOOTING │
                    │ .md             │
                    └─────────────────┘
```

---

## 🚀 Quick Command Decision Matrix

| Situation | Command | Time | What It Checks |
|-----------|---------|------|----------------|
| 🔧 **Quick edit, want fast feedback** | `./scripts/quick_check.sh` | 10s | Dependencies, formatting, syntax, compilation |
| 📝 **About to commit** | `./scripts/pre_commit_check.sh` | 30s | Everything CI checks + TWA + build size |
| 🚀 **About to push** | `./scripts/simulate_ci.sh` | 60s | Complete CI pipeline simulation |
| 🔍 **CI failed, need diagnosis** | `gh run view --log-failed` | 5s | Only failed job logs |
| 📊 **Want detailed CI info** | `gh run view` | 10s | Complete build information |
| ⏰ **Monitor build in real-time** | `./scripts/watch_ci.sh` | Live | Real-time status + auto failure logs |
| 🛠️ **Setup automatic validation** | `./scripts/setup_git_hooks.sh` | Once | Installs pre-commit/pre-push hooks |

---

## 🎯 Situation-Specific Workflows

### 🔧 **Small Bug Fix Workflow**
```
Bug found → Quick fix → ./scripts/quick_check.sh → Commit → Push
   ↓              ↓              ↓                   ↓        ↓
 2 min         1 min         10 sec              30 sec   2 min
```

### 📝 **Feature Development Workflow**
```
Plan feature → Code → Quick check → More code → Pre-commit check → Commit → CI simulation → Push → Monitor
     ↓         ↓         ↓           ↓              ↓           ↓           ↓            ↓       ↓
   5 min    30 min    10 sec     20 min        30 sec      1 min       60 sec       30 sec   5 min
```

### 🏗️ **Major Refactor Workflow**
```
Plan → Code → Frequent quick checks → Pre-commit check → CI simulation → Commit → Push → Monitor
  ↓     ↓              ↓                    ↓              ↓           ↓        ↓       ↓
2 hrs  4 hrs     Every 30 min           30 sec         60 sec      1 min    30 sec   10 min
```

---

## 🚨 Error Recovery Flowchart

```
                    ❌ CI Failed
                         │
                         ▼
              ┌─────────────────────┐
              │ Check Error Type    │
              │ gh run view         │
              │ --log-failed        │
              └──────────┬──────────┘
                         │
           ┌─────────────┼─────────────┐
           ▼             ▼             ▼
   🎨 Formatting    🔍 Analysis    🧪 Test
     Error           Error         Failure
           │             │             │
           ▼             ▼             ▼
   dart format .   Fix warnings   dart test
           │             │             │
           └─────────────┼─────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ Test Fix Locally    │
              │ ./scripts/          │
              │ simulate_ci.sh      │
              └──────────┬──────────┘
                         │
                    ┌────┴────┐
                    ▼         ▼
                ✅ Pass   ❌ Still
                    │      Failing
                    │         │
                    ▼         ▼
            ┌─────────────┐ ┌──────────────┐
            │ Commit &    │ │ Check        │
            │ Push Fix    │ │ TROUBLESHOOT │
            └─────────────┘ │ ING.md       │
                            └──────────────┘
```

---

## 🔄 Git Hooks Integration Flow

### **With Git Hooks Installed**
```
Developer Types:           Automatic Validation:
git commit       ────────► ./scripts/pre_commit_check.sh
     │                              │
     │ ✅ Pass                      │ ❌ Fail
     ▼                              ▼
Commit Created     ──────────► Commit Blocked
     │                        Fix Required
     ▼
git push         ────────► ./scripts/simulate_ci.sh
     │                              │
     │ ✅ Pass                      │ ❌ Fail
     ▼                              ▼
Push Succeeds      ──────────► Push Blocked
     │                        Fix Required
     ▼
Monitor with      ────────► ./scripts/watch_ci.sh
watch_ci.sh                  (automatic)
```

### **Without Git Hooks (Manual)**
```
Developer Must Remember:
Code → ./scripts/quick_check.sh → Fix → ./scripts/pre_commit_check.sh →
Commit → ./scripts/simulate_ci.sh → Fix → Push → gh run watch
```

---

## 📱 Mobile/Termux Optimized Flow

### **Data-Conscious Workflow**
```
                    📱 On Mobile Data?
                           │
                           ▼
                    ┌─────────────┐
                    │ Use Minimal │
                    │ Commands    │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
   Quick Check      Commit Check     CI Monitor
./scripts/quick_  ./scripts/pre_   gh run list
check.sh         commit_check.sh   --limit 3
(10s, <1MB)      (30s, <2MB)      (<0.1MB)
```

### **Offline Development**
```
                    🔌 No Internet?
                           │
                           ▼
                  ┌─────────────────┐
                  │ Local Tools     │
                  │ Only            │
                  └────────┬────────┘
                           │
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
    dart format .   dart analyze   dart test
                           │
                           ▼
                  ./scripts/quick_check.sh
                  (works offline)
                           │
                           ▼
                   When online: Push
```

---

## 🎯 Efficiency Optimization

### **Time vs Thoroughness Matrix**

```
                    Thoroughness
                         ▲
                         │
    simulate_ci.sh ●     │     ● Full CI Run
    (60s, local)         │     (5 min, remote)
                         │
                         │
pre_commit_check.sh ●   │   ● Manual Testing
    (30s)                │   (Variable)
                         │
                         │
    quick_check.sh ●     │     ● No Validation
    (10s)                │     (0s)
                         │
                         └──────────────────► Time
                        10s   30s   60s   5min
```

### **Recommended Usage Patterns**

#### **🏃‍♂️ Speed-First (Development)**
```
Code changes → quick_check.sh → Continue coding
              (Every 15-30 min)
```

#### **⚖️ Balanced (Regular commits)**
```
Code changes → quick_check.sh → pre_commit_check.sh → Commit
              (During dev)     (Before commit)
```

#### **🛡️ Safety-First (Important changes)**
```
Code changes → quick_check.sh → pre_commit_check.sh → simulate_ci.sh → Commit → Push
              (During dev)     (Before commit)      (Before push)
```

---

## 🔧 Tool Comparison

| Tool | Speed | Coverage | Use Case | Output |
|------|-------|----------|----------|--------|
| `quick_check.sh` | ⚡⚡⚡ | 🔍🔍 | Development loop | Minimal |
| `pre_commit_check.sh` | ⚡⚡ | 🔍🔍🔍🔍 | Before commits | Detailed |
| `simulate_ci.sh` | ⚡ | 🔍🔍🔍🔍🔍 | Before pushes | Complete |
| `gh run watch` | ⚡⚡⚡ | 🔍🔍🔍🔍🔍 | Monitor CI | Real-time |

**Legend:**
- ⚡ = Fast (10s), ⚡⚡ = Medium (30s), ⚡⚡⚡ = Instant
- 🔍 = Basic checks, 🔍🔍🔍🔍🔍 = Complete CI validation

---

## 🎪 Decision Tree for Common Scenarios

### **"Should I commit this change?"**
```
Change made → ./scripts/pre_commit_check.sh
                     │
                ┌────┴────┐
                ▼         ▼
            ✅ Pass   ❌ Fail
                │         │
                ▼         ▼
          Safe to     Fix issues
          commit      then retry
```

### **"Should I push to GitHub?"**
```
Ready to push → ./scripts/simulate_ci.sh
                      │
                 ┌────┴────┐
                 ▼         ▼
             ✅ Pass   ❌ Fail
                 │         │
                 ▼         ▼
           Safe to push  Fix issues
           CI will pass  then retry
```

### **"CI failed, what now?"**
```
CI failed → gh run view --log-failed
                  │
            ┌─────┴─────┐
            ▼           ▼
      Known error   Unknown error
            │               │
            ▼               ▼
      Apply quick      Check TROUBLESHOOTING.md
      fix from         for similar issues
      this guide
```

---

This flowchart provides visual guidance for efficient development workflow decisions, helping developers choose the right tool for each situation and optimize their development speed while maintaining code quality.