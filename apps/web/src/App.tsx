import { useEffect, useState } from "react";

function App() {
  const [message, setMessage] = useState("");

  useEffect(() => {
    fetch("http://localhost:3001/health")
      .then((res) => res.json())
      .then((data) => setMessage(data.status));
  }, []);

  useEffect(() => {
    fetch("http://localhost:3001/api/patients")
      .then((res) => res.json())
      .then((data) => console.log(data))
      .catch((err) => console.error(err));
  }, []);

  return (
    <div>
      <h1>Web App</h1>
      <p>{message}</p>
    </div>
  );
}

export default App;
