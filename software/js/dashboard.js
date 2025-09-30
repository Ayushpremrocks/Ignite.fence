// =======================
// Global Variables
// =======================
let adminAlertCount = 0;
let userAlertCount = 0;
let powerChart;

// Config: set PROXY_BASE to route through a CORS-friendly proxy (leave empty for direct calls)
// Example local proxy: 'http://localhost:3001/' then API_URL becomes 'http://localhost:3001/fetch_data'
const EXTERNAL_API = "https://ecomlancers.com/Sih_Api/fetch_data";
const PROXY_BASE = "http://localhost:3001/";
const API_URL = EXTERNAL_API ? `${EXTERNAL_API}fetch_data` : EXTERNAL_API;

// Lazy loader for Chart.js if CDN didn't load yet
let chartJsLoadPromise = null;
function loadChartJsIfNeeded() {
  if (typeof Chart !== "undefined") return Promise.resolve();
  if (chartJsLoadPromise) return chartJsLoadPromise;
  chartJsLoadPromise = new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://cdn.jsdelivr.net/npm/chart.js";
    script.async = true;
    script.onload = () => resolve();
    script.onerror = (e) => reject(new Error("Failed to load Chart.js"));
    document.head.appendChild(script);
  });
  return chartJsLoadPromise;
}

// Utility: Show a text message below the chart area
function showChartInfoMessage(text) {
  const canvas = document.getElementById("powerChart");
  if (!canvas) return;
  const parent = canvas.parentElement;
  if (!parent) return;
  let info = parent.querySelector(".chart-info");
  if (!info) {
    info = document.createElement("div");
    info.className = "chart-info";
    info.style.color = "#aab6c4";
    info.style.marginTop = "8px";
    parent.appendChild(info);
  }
  info.textContent = text;
}

// Normalize API reading objects into a consistent shape
function normalizeReadings(raw) {
  if (!Array.isArray(raw)) return [];
  return raw
    .map((item) => {
      const r = item || {};
      // created_at variations
      const created_at =
        r.created_at || r.time || r.timestamp || r.createdAt || r.ts || null;
      // numeric fields variations
      const voltage =
        r.voltage ?? r.volt ?? r.v ?? r.voltage_value ?? r.V ?? null;
      const current =
        r.current ?? r.amp ?? r.i ?? r.current_value ?? r.A ?? null;
      const power = r.power ?? r.watt ?? r.p ?? r.power_value ?? r.W ?? null;
      return { created_at, voltage, current, power };
    })
    .filter(
      (r) =>
        r.created_at !== null ||
        r.voltage !== null ||
        r.current !== null ||
        r.power !== null
    );
}

// Try to sort readings chronologically if possible
function sortReadingsChronologically(readings) {
  const parseTs = (val) => {
    if (!val) return NaN;
    // If format is "YYYY-MM-DD HH:MM:SS", Date.parse should work in most cases
    const s = String(val);
    // Normalize space-separated date-time to ISO-like by replacing first whitespace with 'T'
    const isoish = s.replace(/\s+/, "T");
    const parsed = Date.parse(isoish);
    if (!isNaN(parsed)) return parsed;
    // If it's just HH:MM:SS, prefix an arbitrary date
    if (/^\d{1,2}:\d{2}:\d{2}$/.test(isoish)) {
      return Date.parse(`1970-01-01T${isoish}Z`);
    }
    // Fallback: try number
    const n = Number(s);
    return isNaN(n) ? NaN : n;
  };
  return readings
    .slice()
    .sort((a, b) => parseTs(a.created_at) - parseTs(b.created_at));
}

// =======================
// Navbar Navigation
// =======================
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".topnav a[data-page]").forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();

      // remove active class
      document
        .querySelectorAll(".topnav a")
        .forEach((a) => a.classList.remove("active"));
      link.classList.add("active");

      // hide all pages
      document
        .querySelectorAll(".page")
        .forEach((p) => p.classList.remove("active"));

      // show selected page
      const pageId = link.getAttribute("data-page");
      document.getElementById(pageId)?.classList.add("active");
    });
  });
});

// =======================
// Admin Login
// =======================
const adminLoginForm = document.getElementById("adminLoginForm");
const adminContent = document.getElementById("adminContent");

if (adminLoginForm) {
  adminLoginForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const user = document.getElementById("adminUser").value;
    const pass = document.getElementById("adminPass").value;

    if (user === "admin" && pass === "1234") {
      alert("Admin login successful!");
      document.getElementById("adminLogin").style.display = "none";
      adminContent.style.display = "block";
      startAdminViolationSimulation(); // 🚨 start admin live violations
    } else {
      alert("Invalid credentials (use admin / 1234)");
    }
  });
}

// =======================
// Add User Form (Admin)
// =======================
const addUserForm = document.getElementById("addUserForm");
const usersTable = document
  .getElementById("usersTable")
  ?.querySelector("tbody");

if (addUserForm) {
  addUserForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const name = document.getElementById("userName").value;
    const email = document.getElementById("userEmail").value;
    const role = document.getElementById("userRole").value;

    const row = document.createElement("tr");
    row.innerHTML = `<td>${name}</td><td>${email}</td><td>${role}</td>`;
    usersTable.appendChild(row);

    addUserForm.reset();
  });
}

// =======================
// User Login
// =======================
const userLoginForm = document.getElementById("userLoginForm");
const userContent = document.getElementById("userContent");

if (userLoginForm) {
  userLoginForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const user = document.getElementById("userNameLogin").value;
    const pass = document.getElementById("userPassLogin").value;

    if (user === "user" && pass === "1234") {
      alert("User login successful!");
      document.getElementById("userLogin").style.display = "none";
      userContent.style.display = "block";

      // Call API-based chart
      fetchPowerReadings();
      setInterval(fetchPowerReadings, 5000);

      startViolationSimulation();
    } else {
      alert("Invalid credentials (use user / 1234)");
    }
  });
}

// =======================
// Add/Delete Meters (User)
// =======================
const addMeterForm = document.getElementById("addMeterForm");
const metersList = document.getElementById("metersList");

if (addMeterForm) {
  addMeterForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const name = document.getElementById("meterName").value;

    const li = document.createElement("li");
    li.innerHTML = `${name} <button class="deleteBtn">Delete</button>`;

    li.querySelector(".deleteBtn").addEventListener("click", () => {
      li.remove();
    });

    metersList.appendChild(li);
    addMeterForm.reset();
  });
}

// =======================
// Fetch Power Data from API
// =======================
// Try multiple request strategies to maximize compatibility
async function requestPowerData(deviceId = 1) {
  const url = API_URL;

  // Helper: timeout via AbortController
  const fetchWithTimeout = (input, init = {}, timeoutMs = 8000) => {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeoutMs);
    const opts = {
      ...init,
      signal: controller.signal,
      mode: "cors",
      credentials: "omit",
      cache: "no-cache",
    };
    return fetch(input, opts).finally(() => clearTimeout(id));
  };

  // Strategy 1: POST JSON
  try {
    const res = await fetchWithTimeout(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ device_id: deviceId }),
    });
    const json = await res.json();
    if (json && (json.code === 200 || json.success === true)) return json;
    console.warn("Strategy1 (POST JSON) returned non-OK response:", json);
  } catch (e) {
    console.warn("Strategy1 (POST JSON) failed:", e);
  }

  // Strategy 2: POST form-urlencoded
  try {
    const res = await fetchWithTimeout(url, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `device_id=${encodeURIComponent(deviceId)}`,
    });
    const json = await res.json();
    if (json && (json.code === 200 || json.success === true)) return json;
    console.warn("Strategy2 (POST form) returned non-OK response:", json);
  } catch (e) {
    console.warn("Strategy2 (POST form) failed:", e);
  }

  // Strategy 3: GET with query params
  try {
    const res = await fetchWithTimeout(
      `${url}?device_id=${encodeURIComponent(deviceId)}`,
      {
        method: "GET",
        headers: { Accept: "application/json" },
      }
    );
    const json = await res.json();
    if (json && (json.code === 200 || json.success === true)) return json;
    console.warn("Strategy3 (GET) returned non-OK response:", json);
  } catch (e) {
    console.warn("Strategy3 (GET) failed:", e);
  }

  throw new Error("All API request strategies failed");
}

async function fetchPowerReadings() {
  try {
    const response = await requestPowerData(1);

    if (response.code === 200 || response.success === true) {
      let readings = [];

      // Handle both array and JSON-string payloads
      if (Array.isArray(response.data)) {
        readings = response.data;
      } else if (typeof response.data === "string") {
        try {
          readings = JSON.parse(response.data);
        } catch (e) {
          console.error("Failed to parse API data string:", e);
        }
      } else if (typeof response.data === "object" && response.data !== null) {
        // Some APIs might wrap data differently
        readings = response.data.readings || [];
      }

      console.debug("Raw response.data type:", typeof response.data);
      if (typeof response.data === "string") {
        console.debug(
          "Raw response.data (truncated):",
          response.data.slice(0, 200)
        );
      }

      if (!Array.isArray(readings)) {
        console.warn(
          "Unexpected readings format; coercing to empty array.",
          readings
        );
        readings = [];
      }

      // Normalize and sort
      readings = normalizeReadings(readings);
      readings = sortReadingsChronologically(readings);

      if (readings.length === 0) {
        console.warn("⚠️ API returned no usable readings.");
        showChartInfoMessage("No data available from API.");
        return; // Do not draw random data
      }

      // Use most recent 6 entries (chronologically sorted -> take last 6)
      const latest = readings.slice(-6);
      console.debug("Updating chart with readings:", latest);
      updatePowerChart(latest);
    } else {
      console.error("API error:", response);
      showChartInfoMessage("Failed to load data from API.");
    }
  } catch (err) {
    console.error("Fetch error:", err);
    showChartInfoMessage("Unable to reach API. Please try again later.");
  }
}

// =======================
// Render / Update Power Chart
// =======================
async function updatePowerChart(readings) {
  // Derive human-friendly labels from created_at supporting formats:
  // - "YYYY-MM-DD HH:MM:SS"
  // - "HH:MM:SS"
  // - timestamp or other strings -> show as-is
  const labels = readings.map((r) => {
    const raw0 = r && r.created_at ? String(r.created_at) : "";
    // Normalize any whitespace (spaces, tabs, newlines) to a single space
    const raw = raw0.replace(/\s+/g, " ").trim();
    // Prefer extracting explicit HH:MM:SS if present
    const m = raw.match(/\b(\d{1,2}:\d{2}:\d{2})\b/);
    if (m) return m[1];
    // Otherwise, if it's a date-time, show the second token as time
    if (raw.includes(" ") || raw.includes("T")) {
      const parts = raw.split(/[ T]/);
      return parts[1] || parts[0] || "N/A";
    }
    return raw || "N/A";
  });

  const voltageValues = readings.map((r) => parseFloat(r.voltage) || 0);
  const currentValues = readings.map((r) => parseFloat(r.current) || 0);
  const powerValues = readings.map((r) => parseFloat(r.power) || 0);

  const canvas = document.getElementById("powerChart");
  if (!canvas) {
    console.warn("powerChart canvas not found. Skipping chart update.");
    return;
  }
  const ctx = canvas.getContext("2d");

  if (typeof Chart === "undefined") {
    try {
      console.warn("Chart.js not found, attempting dynamic load...");
      await loadChartJsIfNeeded();
    } catch (e) {
      console.error("Chart.js failed to load:", e);
      const parent = canvas.parentElement;
      if (parent && !parent.querySelector(".chart-error")) {
        const msg = document.createElement("div");
        msg.className = "chart-error";
        msg.style.color = "#fca5a5";
        msg.style.marginTop = "8px";
        msg.textContent = "Unable to render chart: Chart.js not loaded.";
        parent.appendChild(msg);
      }
      return;
    }
  }

  if (powerChart) powerChart.destroy();

  powerChart = new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: "Voltage (V)",
          data: voltageValues,
          borderColor: "#f59e0b",
          backgroundColor: "rgba(245, 158, 11, 0.2)",
          fill: true,
          tension: 0.3,
        },
        {
          label: "Current (A)",
          data: currentValues,
          borderColor: "#10b981",
          backgroundColor: "rgba(16, 185, 129, 0.2)",
          fill: true,
          tension: 0.3,
        },
        {
          label: "Power (W)",
          data: powerValues,
          borderColor: "#06b6d4",
          backgroundColor: "rgba(6, 182, 212, 0.2)",
          fill: true,
          tension: 0.3,
        },
      ],
    },
    options: {
      responsive: true,
      animation: false,
      plugins: {
        legend: { labels: { color: "#eaf4ff" } },
      },
      scales: {
        x: { ticks: { color: "#aab6c4" } },
        y: { ticks: { color: "#aab6c4" }, beginAtZero: true },
      },
    },
  });
}

// =======================
// Notifications + Badges
// =======================
function showNotification(message) {
  const container = document.getElementById("notificationContainer");
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = message;

  container.appendChild(toast);

  setTimeout(() => {
    toast.remove();
  }, 4000);
}

function updateBadge(panel, count) {
  const navLink = document.querySelector(`.topnav a[data-page="${panel}"]`);
  if (!navLink) return;

  let badge = navLink.querySelector(".badge");
  if (!badge) {
    badge = document.createElement("span");
    badge.className = "badge";
    navLink.appendChild(badge);
  }
  badge.textContent = count;
}

// =======================
// Beep Sounds
// =======================
function playUserBeep() {
  const sound = document.getElementById("userBeep");
  if (sound) {
    sound.currentTime = 0;
    sound.play();
  }
}

function playAdminBeep() {
  const sound = document.getElementById("adminBeep");
  if (sound) {
    sound.currentTime = 0;
    sound.play();
  }
}

// =======================
// Dynamic User Violations
// =======================
const violationTypes = [
  "Voltage Drop",
  "Fence Tamper",
  "Current Surge",
  "Wire Cut",
  "Power Failure",
];

function startViolationSimulation() {
  const tableBody = document
    .getElementById("userViolationsTable")
    .querySelector("tbody");

  setInterval(() => {
    const now = new Date();
    const time = `${now.getHours()}:${String(now.getMinutes()).padStart(
      2,
      "0"
    )}:${String(now.getSeconds()).padStart(2, "0")}`;
    const violation =
      violationTypes[Math.floor(Math.random() * violationTypes.length)];

    const row = document.createElement("tr");
    row.innerHTML = `<td>${time}</td><td>${violation}</td>`;
    tableBody.prepend(row);

    if (tableBody.rows.length > 6) tableBody.deleteRow(-1);

    userAlertCount++;
    updateBadge("user", userAlertCount);
    showNotification(`User Violation: ${violation}`);
    playUserBeep();
  }, 5000);
}

// =======================
// Dynamic Admin Violations
// =======================
function startAdminViolationSimulation() {
  const tableBody = document
    .getElementById("violationsTable")
    .querySelector("tbody");
  const users = ["Farmer A", "Guard B", "User X", "Admin Y"];

  setInterval(() => {
    const now = new Date();
    const time = `${now.getHours()}:${String(now.getMinutes()).padStart(
      2,
      "0"
    )}:${String(now.getSeconds()).padStart(2, "0")}`;
    const user = users[Math.floor(Math.random() * users.length)];
    const violation =
      violationTypes[Math.floor(Math.random() * violationTypes.length)];

    const row = document.createElement("tr");
    row.innerHTML = `<td>${user}</td><td>${time}</td><td>${violation}</td>`;
    tableBody.prepend(row);

    if (tableBody.rows.length > 8) tableBody.deleteRow(-1);

    adminAlertCount++;
    updateBadge("admin", adminAlertCount);
    showNotification(`Admin: ${user} → ${violation}`);
    playAdminBeep();
  }, 7000);
}

// =======================
// Logout Buttons (Admin + User)
// =======================
const adminLogoutBtn = document.getElementById("adminLogoutBtn");
if (adminLogoutBtn) {
  adminLogoutBtn.addEventListener("click", () => {
    alert("Admin logged out!");
    window.location.href = "index.html";
  });
}

const userLogoutBtn = document.getElementById("userLogoutBtn");
if (userLogoutBtn) {
  userLogoutBtn.addEventListener("click", () => {
    alert("User logged out!");
    window.location.href = "index.html";
  });
}
