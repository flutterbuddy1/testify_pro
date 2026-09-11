import React, { useState, useEffect } from 'react';

export default function App() {
  const [activeTab, setActiveTab] = useState('data-runner');
  const [copiedUrl, setCopiedUrl] = useState(false);
  const [copiedCli, setCopiedCli] = useState(false);
  const [schemaCopied, setSchemaCopied] = useState(false);
  const [detectedOs, setDetectedOs] = useState('mac');

  useEffect(() => {
    const userAgent = window.navigator.userAgent.toLowerCase();
    if (userAgent.indexOf('win') !== -1) {
      setDetectedOs('windows');
    } else if (userAgent.indexOf('mac') !== -1) {
      setDetectedOs('mac');
    } else {
      setDetectedOs('linux');
    }
  }, []);

  const schemaUrl = `${window.location.origin}${window.location.pathname.replace(/\/$/, '')}/schemas/flow.v1.json`;

  const handleCopySchemaUrl = () => {
    navigator.clipboard.writeText(schemaUrl);
    setCopiedUrl(true);
    setTimeout(() => setCopiedUrl(false), 2500);
  };

  const handleCopyCli = () => {
    navigator.clipboard.writeText('testify run -c collection.json -d dataset.csv --reporters cli,html');
    setCopiedCli(true);
    setTimeout(() => setCopiedCli(false), 2500);
  };

  return (
    <div className="app-wrapper">
      <div className="ambient-bg"></div>
      <div className="ambient-grid"></div>

      {/* Navigation */}
      <header className="navbar">
        <div className="container nav-inner">
          <a href="#" className="brand" id="brand-logo">
            <div className="brand-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
            </div>
            <span>Testify Pro</span>
            <span className="brand-badge">v1.0</span>
          </a>

          <nav>
            <ul className="nav-links">
              <li><a href="#features" className="nav-link">Features</a></li>
              <li><a href="#data-runner" className="nav-link">Data Runner</a></li>
              <li><a href="#schema" className="nav-link">Flow Schema</a></li>
              <li><a href="#cli" className="nav-link">CLI</a></li>
              <li><a href="#downloads" className="nav-link">Downloads</a></li>
            </ul>
          </nav>

          <div className="nav-actions">
            <a href="#downloads" className="btn btn-primary" id="nav-download-btn">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
              </svg>
              <span>Download</span>
            </a>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="hero">
        <div className="container">
          <div className="status-pill" id="hero-badge">
            <span className="pulse-dot"></span>
            <span>Testify Pro v1.0.0 Production Release &bull; Native Desktop App</span>
          </div>

          <h1>
            Next-Gen API Testing &amp; <br />
            <span className="gradient-text">High-Concurrency Load Testing</span>
          </h1>

          <p className="hero-subtitle">
            The local-first API workstation engineered for modern developers. Run multi-row data-driven iterations, 
            execute Postman JS assertion scripts, construct automated flow pipelines, and stress-test endpoints with zero cloud lock-in.
          </p>

          <div className="hero-cta-group">
            <a href="#downloads" className="btn btn-primary btn-lg" id="hero-mac-cta">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.62-.75 1.04-1.8 0.92-2.85-.9.04-2 .6-2.65 1.36-.56.65-.96 1.7-0.82 2.72 1 .08 1.93-.48 2.55-1.23z"/>
              </svg>
              <span>Download for macOS (.dmg)</span>
            </a>

            <a href="#downloads" className="btn btn-secondary btn-lg" id="hero-win-cta">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.901-1.799"/>
              </svg>
              <span>Download for Windows (.exe)</span>
            </a>
          </div>

          <div className="hero-subtext">
            <span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
              Apple Silicon &amp; Intel Support
            </span>
            <span>&bull;</span>
            <span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
              100% Free &amp; Local-First
            </span>
            <span>&bull;</span>
            <span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
              Postman Collection Compatible
            </span>
          </div>

          {/* Interactive Hero Showcase */}
          <div className="hero-showcase">
            <div className="terminal-header">
              <div className="window-dots">
                <div className="dot dot-red"></div>
                <div className="dot dot-yellow"></div>
                <div className="dot dot-green"></div>
              </div>
              <div className="terminal-title">testify-pro-workstation v1.0.0</div>
              <div style={{ width: 48 }}></div>
            </div>

            <div className="terminal-tabs">
              <button 
                className={`tab-btn ${activeTab === 'data-runner' ? 'active' : ''}`}
                onClick={() => setActiveTab('data-runner')}
              >
                <span>📊</span> Data-Driven Runner
              </button>
              <button 
                className={`tab-btn ${activeTab === 'postman-js' ? 'active' : ''}`}
                onClick={() => setActiveTab('postman-js')}
              >
                <span>⚡</span> Postman JS Sandbox
              </button>
              <button 
                className={`tab-btn ${activeTab === 'flow-json' ? 'active' : ''}`}
                onClick={() => setActiveTab('flow-json')}
              >
                <span>🔗</span> Flow Schema JSON
              </button>
              <button 
                className={`tab-btn ${activeTab === 'load-test' ? 'active' : ''}`}
                onClick={() => setActiveTab('load-test')}
              >
                <span>🚀</span> High-Concurrency Load
              </button>
            </div>

            <div className="terminal-body">
              {activeTab === 'data-runner' && (
                <pre>
                  <code>
                    <span className="comment">// Testify Pro Newman-Compatible Multi-Row Runner</span>{'\n'}
                    <span className="prop">Dataset</span>: <span className="str">"sample_users_data.csv"</span> (4 Iterations loaded){'\n'}
                    <span className="prop">Target Flow</span>: <span className="str">"User Onboarding &amp; Role Verification"</span>{'\n'}
                    {'\n'}
                    <span className="kw">Iteration 1/4</span> [userId: 101, role: "admin", status: "active"]{'\n'}
                    &nbsp;&nbsp;✔ <span className="fn">POST</span> /api/v1/auth/login <span className="str">[200 OK]</span> - 24ms{'\n'}
                    &nbsp;&nbsp;✔ <span className="fn">GET</span>  /api/v1/users/101 <span className="str">[200 OK]</span> - 18ms{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;✔ <span className="comment">Assertion</span>: pm.expect(user.role).to.eql("admin") <span className="str">[PASS]</span>{'\n'}
                    {'\n'}
                    <span className="kw">Iteration 2/4</span> [userId: 102, role: "editor", status: "active"]{'\n'}
                    &nbsp;&nbsp;✔ <span className="fn">POST</span> /api/v1/auth/login <span className="str">[200 OK]</span> - 21ms{'\n'}
                    &nbsp;&nbsp;✔ <span className="fn">GET</span>  /api/v1/users/102 <span className="str">[200 OK]</span> - 19ms{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;✔ <span className="comment">Assertion</span>: pm.expect(user.role).to.eql("editor") <span className="str">[PASS]</span>{'\n'}
                    {'\n'}
                    <span className="str">✨ Complete: 4/4 Iterations Passed (100% Success Rate) &bull; HTML Report Generated</span>
                  </code>
                </pre>
              )}

              {activeTab === 'postman-js' && (
                <pre>
                  <code>
                    <span className="comment">// Postman Compatible Test Script in Testify Pro</span>{'\n'}
                    <span className="kw">const</span> response = pm.response.<span className="fn">json</span>();{'\n'}
                    <span className="kw">let</span> expectedRole = pm.iterationData.<span className="fn">get</span>(<span className="str">"role"</span>);{'\n'}
                    {'\n'}
                    pm.<span className="fn">test</span>(<span className="str">"Status code is 200 OK"</span>, <span className="kw">function</span> () &#123;{'\n'}
                    &nbsp;&nbsp;pm.response.to.have.<span className="fn">status</span>(<span className="num">200</span>);{'\n'}
                    &#125;);{'\n'}
                    {'\n'}
                    pm.<span className="fn">test</span>(<span className="str">"Verify user permissions match dataset"</span>, <span className="kw">function</span> () &#123;{'\n'}
                    &nbsp;&nbsp;pm.<span className="fn">expect</span>(response.data.role).to.<span className="fn">eql</span>(expectedRole);{'\n'}
                    &nbsp;&nbsp;pm.<span className="fn">expect</span>(response.data.isActive).to.be.<span className="num">true</span>;{'\n'}
                    &#125;);{'\n'}
                    {'\n'}
                    <span className="comment">// Save session token for downstream pipeline steps</span>{'\n'}
                    pm.environment.<span className="fn">set</span>(<span className="str">"authToken"</span>, response.token);
                  </code>
                </pre>
              )}

              {activeTab === 'flow-json' && (
                <pre>
                  <code>
                    &#123;{'\n'}
                    &nbsp;&nbsp;<span className="prop">"$schema"</span>: <span className="str">"https://testifypro.dev/schemas/flow.v1.json"</span>,{'\n'}
                    &nbsp;&nbsp;<span className="prop">"name"</span>: <span className="str">"Automated E-Commerce Checkout Pipeline"</span>,{'\n'}
                    &nbsp;&nbsp;<span className="prop">"variables"</span>: &#123; <span className="prop">"baseUrl"</span>: <span className="str">"https://api.example.com"</span> &#125;,{'\n'}
                    &nbsp;&nbsp;<span className="prop">"steps"</span>: [{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&#123;{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"name"</span>: <span className="str">"1. Authenticate Customer"</span>,{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"request"</span>: &#123; <span className="prop">"method"</span>: <span className="str">"POST"</span>, <span className="prop">"url"</span>: <span className="str">"&#123;&#123;baseUrl&#125;&#125;/auth"</span> &#125;,{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"extractors"</span>: [&#123; <span className="prop">"type"</span>: <span className="str">"jsonPath"</span>, <span className="prop">"expression"</span>: <span className="str">"$.token"</span>, <span className="prop">"variableName"</span>: <span className="str">"userToken"</span> &#125;]{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&#125;,{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&#123;{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"name"</span>: <span className="str">"2. Process Order with Token"</span>,{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"request"</span>: &#123; <span className="prop">"method"</span>: <span className="str">"POST"</span>, <span className="prop">"url"</span>: <span className="str">"&#123;&#123;baseUrl&#125;&#125;/checkout"</span> &#125;{'\n'}
                    &nbsp;&nbsp;&nbsp;&nbsp;&#125;{'\n'}
                    &nbsp;&nbsp;]{'\n'}
                    &#125;
                  </code>
                </pre>
              )}

              {activeTab === 'load-test' && (
                <pre>
                  <code>
                    <span className="comment">// Testify Pro Real-Time Load Testing Engine</span>{'\n'}
                    Target: <span className="str">https://api.production.internal/v1/orders</span>{'\n'}
                    Concurrency: <span className="num">250 Virtual Users</span> | Ramp-up: <span className="num">10s</span> | Duration: <span className="num">60s</span>{'\n'}
                    {'\n'}
                    <span className="prop">Live Status</span>: <span className="str">Completed</span>{'\n'}
                    &bull; <span className="prop">Total Requests</span>: <span className="num">142,850</span>{'\n'}
                    &bull; <span className="prop">Throughput</span>:     <span className="num">2,380.8 req/sec</span>{'\n'}
                    &bull; <span className="prop">Success Rate</span>:   <span className="str">99.98%</span> (4 errors / 142,850){'\n'}
                    &bull; <span className="prop">P50 Latency</span>:    <span className="num">16.4 ms</span>{'\n'}
                    &bull; <span className="prop">P95 Latency</span>:    <span className="num">38.2 ms</span>{'\n'}
                    &bull; <span className="prop">P99 Latency</span>:    <span className="num">64.1 ms</span>{'\n'}
                    {'\n'}
                    <span className="comment">Interactive Latency Distribution chart and HTML export ready.</span>
                  </code>
                </pre>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="features-section" id="features">
        <div className="container">
          <div className="section-header">
            <span className="section-tag">Powerful Capabilities</span>
            <h2>Built for Speed, Reliability, and Developer Autonomy</h2>
            <p>Everything you need for comprehensive API verification in a clean, responsive desktop environment.</p>
          </div>

          <div className="features-grid">
            {/* Feature 1 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                  <polyline points="14 2 14 8 20 8"></polyline>
                  <line x1="16" y1="13" x2="8" y2="13"></line>
                  <line x1="16" y1="17" x2="8" y2="17"></line>
                  <polyline points="10 9 9 9 8 9"></polyline>
                </svg>
              </div>
              <h3>Data-Driven Iteration Runner</h3>
              <p>
                Import CSV or JSON multi-row datasets to parameterize test execution across hundreds of records. 
                Full variable substitution (`pm.iterationData.get`) and real-time step streaming.
              </p>
              <div className="feature-pill">Newman-Compatible &bull; Multi-Row CSV/JSON</div>
            </div>

            {/* Feature 2 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon>
                </svg>
              </div>
              <h3>Postman JS Sandbox Engine</h3>
              <p>
                Seamlessly run your existing Postman pre-request and test assertion scripts. Supports `pm.test`, 
                `pm.expect`, `pm.environment`, and `pm.variables` without rewriting your tests.
              </p>
              <div className="feature-pill">Full PM Object &bull; Chai Assertions</div>
            </div>

            {/* Feature 3 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
              </div>
              <h3>Visual Flow Pipelines</h3>
              <p>
                Chain dependent requests sequentially. Extract authorization tokens, dynamic order IDs, or cookies 
                from responses and inject them into subsequent API requests with ease.
              </p>
              <div className="feature-pill">Dynamic Extractor &bull; Pipeline Chains</div>
            </div>

            {/* Feature 4 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 12h-4l-3 9L9 3l-3 9H2"></path>
                </svg>
              </div>
              <h3>High-Concurrency Load Engine</h3>
              <p>
                Stress-test microservices with hundreds of concurrent virtual users. Track real-time RPS, 
                error percentages, and accurate P50, P90, P95, and P99 latency percentiles.
              </p>
              <div className="feature-pill">P50 / P95 / P99 Percentiles &bull; Live RPS</div>
            </div>

            {/* Feature 5 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
                  <line x1="8" y1="21" x2="16" y2="21"></line>
                  <line x1="12" y1="17" x2="12" y2="21"></line>
                </svg>
              </div>
              <h3>Responsive HTML Test Reports</h3>
              <p>
                Export executive-ready, interactive HTML test reports with iteration matrixes, assertion badges, 
                keyword search, and print-to-PDF formatting for QA handoffs.
              </p>
              <div className="feature-pill">Searchable Matrix &bull; Print-to-PDF</div>
            </div>

            {/* Feature 6 */}
            <div className="glass-card feature-card">
              <div className="feature-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
              </div>
              <h3>100% Local-First &amp; Private</h3>
              <p>
                No forced logins, no cloud tracking, and no external synchronization of your proprietary API tokens 
                or customer test data. Everything runs securely on your machine.
              </p>
              <div className="feature-pill">Zero Telemetry &bull; Offline Ready</div>
            </div>
          </div>
        </div>
      </section>

      {/* Flow Schema Section */}
      <section className="schema-section" id="schema">
        <div className="container">
          <div className="schema-box">
            <div className="schema-info">
              <span className="section-tag">Standardized Specification</span>
              <h3>Universal Flow JSON Schema</h3>
              <p>
                Testify Pro publishes an official JSON Schema (Draft-07) for flow definitions. Integrate with 
                VS Code, JetBrains IDEs, or automated CI linters for complete schema validation and auto-completion.
              </p>

              <ul className="schema-features">
                <li>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="20 6 9 17 4 12"></polyline>
                  </svg>
                  <span>Real-time syntax validation &amp; autocomplete in IDEs</span>
                </li>
                <li>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="20 6 9 17 4 12"></polyline>
                  </svg>
                  <span>Supports sequential requests, assertions, and variable extractions</span>
                </li>
                <li>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="20 6 9 17 4 12"></polyline>
                  </svg>
                  <span>Automated static schema hosting on GitHub Pages</span>
                </li>
              </ul>

              <div className="schema-url-bar">
                <span className="schema-url-text">./schemas/flow.v1.json</span>
                <button className="btn btn-secondary" onClick={handleCopySchemaUrl} style={{ padding: '6px 12px', fontSize: '0.8rem' }}>
                  {copiedUrl ? 'Copied!' : 'Copy Schema URL'}
                </button>
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <a href="./schemas/flow.v1.json" download="flow.v1.json" className="btn btn-primary">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                  </svg>
                  <span>Download flow.v1.json</span>
                </a>
              </div>
            </div>

            <div className="schema-viewer-card">
              <pre>
                <code>
                  &#123;{'\n'}
                  &nbsp;&nbsp;<span className="prop">"$schema"</span>: <span className="str">"http://json-schema.org/draft-07/schema#"</span>,{'\n'}
                  &nbsp;&nbsp;<span className="prop">"$id"</span>: <span className="str">"https://testifypro.dev/schemas/flow.v1.json"</span>,{'\n'}
                  &nbsp;&nbsp;<span className="prop">"title"</span>: <span className="str">"TestifyPro Flow Schema"</span>,{'\n'}
                  &nbsp;&nbsp;<span className="prop">"type"</span>: <span className="str">"object"</span>,{'\n'}
                  &nbsp;&nbsp;<span className="prop">"required"</span>: [<span className="str">"name"</span>, <span className="str">"steps"</span>],{'\n'}
                  &nbsp;&nbsp;<span className="prop">"properties"</span>: &#123;{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"name"</span>: &#123; <span className="prop">"type"</span>: <span className="str">"string"</span> &#125;,{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"variables"</span>: &#123; <span className="prop">"type"</span>: <span className="str">"object"</span> &#125;,{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"steps"</span>: &#123;{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"type"</span>: <span className="str">"array"</span>,{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="prop">"items"</span>: &#123; <span className="prop">"$ref"</span>: <span className="str">"#/definitions/FlowStep"</span> &#125;{'\n'}
                  &nbsp;&nbsp;&nbsp;&nbsp;&#125;{'\n'}
                  &nbsp;&nbsp;&#125;{'\n'}
                  &#125;
                </code>
              </pre>
            </div>
          </div>
        </div>
      </section>

      {/* CLI Quickstart */}
      <section className="cli-section" id="cli">
        <div className="container">
          <div className="cli-box">
            <div className="cli-info">
              <span className="section-tag">Headless Automation</span>
              <h3>Command Line Interface</h3>
              <p>Run your flow collections and data-driven iterations headlessly in CI/CD pipelines using the standalone Testify CLI runner.</p>
            </div>

            <div className="cli-command-box">
              <span>$ testify run -c collection.json -d data.csv</span>
              <button className="btn btn-secondary" onClick={handleCopyCli} style={{ padding: '6px 12px', fontSize: '0.8rem' }}>
                {copiedCli ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Downloads Section */}
      <section className="downloads-section" id="downloads">
        <div className="container">
          <div className="section-header">
            <span className="section-tag">Get Started Today</span>
            <h2>Download Testify Pro Desktop</h2>
            <p>Free, fast, and local-first. Choose your operating system below.</p>
          </div>

          <div className="downloads-grid">
            {/* macOS Card */}
            <div className="glass-card download-card highlight">
              <div className="platform-header">
                <div className="platform-info">
                  <div className="platform-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.62-.75 1.04-1.8 0.92-2.85-.9.04-2 .6-2.65 1.36-.56.65-.96 1.7-0.82 2.72 1 .08 1.93-.48 2.55-1.23z"/>
                    </svg>
                  </div>
                  <div className="platform-title">
                    <h3>macOS</h3>
                    <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Apple Silicon (arm64) &amp; Intel</p>
                  </div>
                </div>
                <span className="platform-badge">Verified Build</span>
              </div>

              <ul className="download-specs">
                <li>
                  <span>Version</span>
                  <span>v1.0.0 Stable</span>
                </li>
                <li>
                  <span>macOS Requirement</span>
                  <span>macOS 11.0 (Big Sur) or later</span>
                </li>
                <li>
                  <span>Installer Size</span>
                  <span>23 MB (DMG) / 20 MB (ZIP)</span>
                </li>
                <li>
                  <span>Security</span>
                  <span>Gatekeeper &amp; Apple Silicon Native</span>
                </li>
              </ul>

              <div className="download-buttons">
                <a 
                  href="./downloads/TestifyPro-macOS-arm64.dmg" 
                  download="TestifyPro-macOS-arm64.dmg"
                  className="btn btn-primary"
                  id="download-mac-dmg"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                  </svg>
                  <span>Download DMG (Apple Silicon .dmg)</span>
                </a>

                <a 
                  href="./downloads/TestifyPro-macOS-arm64.zip" 
                  download="TestifyPro-macOS-arm64.zip"
                  className="btn btn-secondary"
                  id="download-mac-zip"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                  </svg>
                  <span>Download Portable ZIP (.zip)</span>
                </a>
              </div>
            </div>

            {/* Windows Card */}
            <div className="glass-card download-card">
              <div className="platform-header">
                <div className="platform-info">
                  <div className="platform-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.901-1.799"/>
                    </svg>
                  </div>
                  <div className="platform-title">
                    <h3>Windows</h3>
                    <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Windows 10 / 11 (64-bit)</p>
                  </div>
                </div>
                <span className="platform-badge" style={{ background: 'rgba(99, 102, 241, 0.15)', color: '#A5B4FC', borderColor: 'rgba(99, 102, 241, 0.3)' }}>
                  Release v1.0
                </span>
              </div>

              <ul className="download-specs">
                <li>
                  <span>Version</span>
                  <span>v1.0.0 Stable</span>
                </li>
                <li>
                  <span>Windows Requirement</span>
                  <span>Windows 10 / 11 (x64 architecture)</span>
                </li>
                <li>
                  <span>Architecture</span>
                  <span>64-bit Native Win32</span>
                </li>
                <li>
                  <span>Distribution</span>
                  <span>Setup Installer &amp; Standalone ZIP</span>
                </li>
              </ul>

              <div className="download-buttons">
                <a 
                  href="https://github.com/mayanksmind/testify_pro/releases/latest" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="btn btn-primary"
                  id="download-win-exe"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                  </svg>
                  <span>Download Windows Installer (.exe)</span>
                </a>

                <a 
                  href="https://github.com/mayanksmind/testify_pro/releases/latest" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="btn btn-secondary"
                  id="download-win-zip"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                  </svg>
                  <span>Download Windows Portable (.zip)</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container">
          <div className="footer-inner">
            <div className="brand">
              <div className="brand-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
              </div>
              <span>Testify Pro</span>
            </div>

            <ul className="footer-nav">
              <li><a href="#features">Features</a></li>
              <li><a href="#schema">JSON Schema</a></li>
              <li><a href="#cli">CLI Runner</a></li>
              <li><a href="#downloads">Downloads</a></li>
              <li><a href="https://github.com/mayanksmind/testify_pro" target="_blank" rel="noopener noreferrer">GitHub</a></li>
            </ul>
          </div>

          <div className="footer-bottom">
            <p>&copy; {new Date().getFullYear()} Testify Pro. Designed for high-performance API engineering. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
