import { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState('Loading...');

  useEffect(() => {
    fetch('/api/hello')
      .then(res => res.json())
      .then(data => setMessage(data.message))
      .catch(err => setMessage('Error connecting to backend'));
  }, []);

  return (
    <div style={{ padding: 30 }}>
      <h1>Digital Locker System</h1>
      <p>Backend says: {message}</p>
    </div>
  );
}

export default App;
