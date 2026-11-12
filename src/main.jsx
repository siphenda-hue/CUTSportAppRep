import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import './styles.css';

class AppErrorBoundary extends React.Component {
  state = { error: null };

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    console.error('CUT Sport render failure:', error, info.componentStack);
  }

  render() {
    if (this.state.error) {
      return <StartupFailure error={this.state.error} />;
    }
    return this.props.children;
  }
}

function StartupFailure({ error }) {
  return (
    <main style={{ minHeight: '100vh', padding: '32px 22px', display: 'grid', alignContent: 'center', justifyItems: 'center', gap: '12px', fontFamily: 'system-ui, sans-serif', color: '#10233f', background: '#FBFAF5', textAlign: 'center' }}>
      <strong style={{ color: '#0047B3', letterSpacing: '2px' }}>CUT SPORT</strong>
      <h1 style={{ margin: 0 }}>The app could not start</h1>
      <p style={{ maxWidth: '520px', lineHeight: 1.6 }}>The page loaded, but an application component encountered an error. Please refresh the page. If the problem continues, contact the CUT Sport administrator.</p>
      <details style={{ maxWidth: '520px', width: '100%', textAlign: 'left', padding: '12px', background: '#fff', borderRadius: '10px', overflowWrap: 'anywhere' }}>
        <summary>Technical details</summary>
        <pre style={{ whiteSpace: 'pre-wrap', fontSize: '12px' }}>{String(error?.message || error || 'Unknown application error')}</pre>
      </details>
    </main>
  );
}

const rootElement = document.getElementById('root');
const root = createRoot(rootElement);

if ('serviceWorker' in navigator && import.meta.env.PROD) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch((error) => {
      console.warn('CUT Sport offline support could not be enabled:', error);
    });
  });
}

root.render(<div style={{ padding: '32px', textAlign: 'center', fontFamily: 'system-ui, sans-serif' }}>Loading CUT Sport…</div>);

import('./App.jsx')
  .then(({ default: App }) => {
    root.render(
      <React.StrictMode>
        <BrowserRouter>
          <AppErrorBoundary>
            <App />
          </AppErrorBoundary>
        </BrowserRouter>
      </React.StrictMode>
    );
  })
  .catch((error) => {
    console.error('CUT Sport startup failure:', error);
    root.render(<StartupFailure error={error} />);
  });
