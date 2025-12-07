// app/page.tsx
import Link from "next/link";

export default function Home() {
  return (
    <main className="home-root">
      <div className="home-hero">
        <div className="home-copy">
          <span className="home-badge">LearnLynk Technical Test</span>
          <h1 className="home-title">Admissions CRM mini dashboard</h1>
          <p className="home-subtitle">
            This MVP shows a “Today&apos;s Tasks” view for counselors. Other CRM
            modules (leads, applications, reporting) are planned for later
            iterations.
          </p>

          <Link href="/dashboard/today" className="home-cta">
            Open Today&apos;s Tasks
          </Link>

          <p className="home-hint">
            This is the only interactive screen implemented for the assessment.
          </p>
        </div>

        <div className="home-illustration">
          <div className="home-card">
            <div className="home-card-header">
              <span className="dot dot-red" />
              <span className="dot dot-yellow" />
              <span className="dot dot-green" />
            </div>
            <div className="home-card-body">
              <div className="home-pill-row">
                <span className="home-pill home-pill-blue">Call – Sudha</span>
                <span className="home-pill home-pill-amber">
                  Review – Sana
                </span>
              </div>
              <div className="home-table-skeleton">
                <div className="home-row" />
                <div className="home-row" />
                <div className="home-row" />
              </div>
              <div className="home-footer-note">
                Today&apos;s tasks are fetched from Supabase.
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
