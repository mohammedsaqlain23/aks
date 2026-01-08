## 📂 Repository Structure & File Explanation

This repository uses **Terraform and Helm** to deploy **Datadog on Azure Kubernetes Service (AKS)** in a **secure, GDPR-compliant, and production-ready** manner.
Each file has a **clear responsibility**, explained below.

---

### 📄 provider.tf — Provider & Connectivity Configuration

**Purpose**
Defines and configures the Terraform providers required for this project.

**What it does**
- Connects Terraform to:
  - Azure (azurerm)
  - Kubernetes (kubernetes)
  - Helm (helm)
- Authenticates Terraform with the AKS cluster
- Enables Helm to install Datadog inside Kubernetes

**Why it’s needed**
Without this file, Terraform would not know **where** or **how** to deploy resources.

---

### 📄 main.tf — Core Deployment Logic

**Purpose**
Contains the main infrastructure logic.

**What it does**
- Creates a Kubernetes Secret for the Datadog API key
- Deploys Datadog using the Helm chart
- Installs:
  - Datadog Agent (DaemonSet)
  - Datadog Cluster Agent
  - Datadog Operator (if enabled)
- Applies configuration from `datadog-values.yaml`

**Why it’s needed**
This file defines **what gets deployed** and **how Datadog is installed** in the AKS cluster.

---

### 📄 variables.tf — Input Variable Definitions

**Purpose**
Defines all input variables used by the Terraform configuration.

**What it does**
- Declares variables such as:
  - AKS cluster name
  - Resource group name
  - Environment (dev, staging, prod)
  - Datadog API key (passed securely)

**Why it’s needed**
Keeps the code **reusable**, **clean**, and **environment-agnostic** without hardcoding values.

---

### 📄 datadog-values.yaml — Datadog Configuration & Policies

**Purpose**
Controls Datadog’s runtime behavior inside the AKS cluster.

**What it does**
- Uses Datadog **EU site (`datadoghq.eu`)** for GDPR compliance
- Enables:
  - Log collection
  - APM (Application Performance Monitoring)
- Drops logs at agent level:
  - INFO logs (cost optimization)
  - Kubernetes health checks
  - Emails, tokens, authorization headers (PII protection)
- Allows:
  - WARN, ERROR, and CRITICAL logs to appear in Datadog UI

**Why it’s needed**
Separates **observability policy** from Terraform logic and ensures **privacy, compliance, and cost control**.

---

## 🔐 Datadog API Key Configuration

The Datadog API key is required to authenticate the Datadog Agent with Datadog.

⚠️ **For security reasons, the API key is NOT stored in the repository or code.**

---

### ✅ Export Datadog API Key (Required)

Before running Terraform, export the Datadog API key as an environment variable:

```bash
export TF_VAR_datadog_api_key="YOUR_DATADOG_API_KEY"
