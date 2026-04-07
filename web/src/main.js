import './style.css';

// Mock Data for Tel-U Care Reports
const MOCK_REPORTS = [
  {
    id: 1,
    title: "AC di GKU lt. 3 Mati",
    description: "Sudah 3 hari AC di ruang tutorial 305 mati total. Sangat mengganggu proses belajar mengajar karena ruangan pengap.",
    author: "Iqbal @ GKU",
    upvotes: 142,
    status: "progress",
    category: "Fasilitas Kampus",
    time: "2 jam yang lalu",
    image: "https://images.unsplash.com/photo-1545239351-ef35f43d514b?auto=format&fit=crop&q=80&w=800"
  },
  {
    id: 2,
    title: "Kran Air Masjid Terbuka",
    description: "Kran air di area wudhu pria patah dan air mengalir terus menerus. Mohon segera diperbaiki untuk menghemat air.",
    author: "Syahrul @ Masjid",
    upvotes: 89,
    status: "pending",
    category: "Sanitasi",
    time: "5 jam yang lalu",
    image: "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=800"
  },
  {
    id: 3,
    title: "Wifi FIT Gedung Selaru Lemot",
    description: "Koneksi wifi di lantai 2 gedung Selaru seringkali RTO, sangat menyulitkan saat praktikum.",
    author: "Dina @ FIT",
    upvotes: 215,
    status: "progress",
    category: "IT Support",
    time: "1 jam yang lalu",
    image: "https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&q=80&w=800"
  },
  {
    id: 4,
    title: "Lampu Lorong TULT Padam",
    description: "Sepanjang koridor lantai 12 lampu banyak yang mati, membahayakan di malam hari.",
    author: "Rafi @ TULT",
    upvotes: 56,
    status: "resolved",
    category: "Kelistrikan",
    time: "1 hari yang lalu",
    image: "https://images.unsplash.com/photo-1517581177682-a085bb7ffb15?auto=format&fit=crop&q=80&w=800"
  }
];

const app = document.querySelector('#app');

function renderDashboard() {
  app.innerHTML = `
    <aside class="sidebar glass">
      <div class="logo">
        <div class="logo-dot"></div>
        <span>Tel-U Care</span>
      </div>
      
      <ul class="nav-menu">
        <li class="nav-item active">
          <span>🏠</span>
          <span>Feed Dashboard</span>
        </li>
        <li class="nav-item">
          <span>📈</span>
          <span>Trending Reports</span>
        </li>
        <li class="nav-item">
          <span>📋</span>
          <span>My Reports</span>
        </li>
        <li class="nav-item">
          <span>⚙️</span>
          <span>Settings</span>
        </li>
      </ul>

      <div style="margin-top: auto;">
        <button class="cta-button" id="create-report-btn">
          Create New Report
        </button>
      </div>
    </aside>

    <main class="main-content">
      <header class="header">
        <div class="search-bar glass">
          <span>🔍</span>
          <input type="text" placeholder="Search facilities, tickets, or issues...">
        </div>
        
        <div class="user-profile">
          <div class="meta-item">
            <strong>Student Portal</strong>
          </div>
          <div class="avatar">IH</div>
        </div>
      </header>

      <div class="dashboard-grid">
        <section class="feed-section">
          <h2>Campus Feedback Hub</h2>
          <div id="report-feed">
            ${MOCK_REPORTS.map(report => `
              <div class="report-card glass animate-in">
                <div class="report-content">
                  <div class="vote-control">
                    <button class="vote-btn">▲</button>
                    <span class="vote-count">${report.upvotes}</span>
                    <button class="vote-btn">▼</button>
                  </div>
                  
                  <div class="report-details">
                    <div class="report-header">
                      <h3 class="report-title">${report.title}</h3>
                      <span class="status-badge status-${report.status}">${report.status}</span>
                    </div>
                    <p class="report-desc">${report.description}</p>
                    
                    <div class="report-meta">
                      <div class="meta-item"><span>👤</span> ${report.author}</div>
                      <div class="meta-item"><span>📅</span> ${report.time}</div>
                      <div class="meta-item"><span>🏷️</span> ${report.category}</div>
                    </div>

                    ${report.image ? `
                      <div class="report-image" style="background-image: url('${report.image}')">
                        <div class="image-overlay"></div>
                      </div>
                    ` : ''}
                  </div>
                </div>
              </div>
            `).join('')}
          </div>
        </section>

        <section class="secondary-section">
          <div class="stats-card glass">
            <h3 class="stats-title">🔥 Trending Issues</h3>
            <ul class="trending-list">
              <li class="trending-item">
                <span class="trending-topic">#AC-GKU-Mati</span>
                <span class="trending-count">1.2k upvotes today</span>
              </li>
              <li class="trending-item">
                <span class="trending-topic">#TULT-Lampu</span>
                <span class="trending-count">850 upvotes</span>
              </li>
              <li class="trending-item">
                <span class="trending-topic">#Wifi-Slow</span>
                <span class="trending-count">2.3k mentions</span>
              </li>
            </ul>
          </div>

          <div class="stats-card glass">
            <h3 class="stats-title">🏛️ Facility Status</h3>
            <div style="margin-top: 1rem;">
              <div style="display:flex; justify-content:space-between; margin-bottom: 0.5rem; font-size: 0.9rem;">
                <span>Maintenance Speed</span>
                <span>82%</span>
              </div>
              <div style="height: 8px; background: rgba(0,0,0,0.05); border-radius: 10px; overflow: hidden;">
                <div style="width: 82%; height: 100%; background: var(--primary);"></div>
              </div>
            </div>
            <div style="margin-top: 1.5rem;">
              <div style="display:flex; justify-content:space-between; margin-bottom: 0.5rem; font-size: 0.9rem;">
                <span>Student Satisfaction</span>
                <span>4.8/5.0</span>
              </div>
              <div style="height: 8px; background: rgba(0,0,0,0.05); border-radius: 10px; overflow: hidden;">
                <div style="width: 96%; height: 100%; background: var(--accent);"></div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  `;

  // Add micro-interactions
  document.querySelectorAll('.vote-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const countEl = e.target.parentElement.querySelector('.vote-count');
      let count = parseInt(countEl.innerText);
      if (e.target.innerText === '▲') count++;
      else count--;
      countEl.innerText = count;
      
      // Visual feedback
      e.target.style.color = 'var(--primary)';
      setTimeout(() => e.target.style.color = '', 300);
    });
  });
}

renderDashboard();
