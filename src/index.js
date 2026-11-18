document.addEventListener("DOMContentLoaded", async () => {
  console.log("UniPath frontend loaded successfully.");
  const testBox = document.getElementById("testing");
  if (!testBox) return;

  try {
    const response = await fetch("/api/test", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "This is a test" }),
    });
    if (!response.ok) throw new Error(`API request failed: ${response.status}`);
    const data = await response.json();
    testBox.textContent = data.message;
  } catch (error) {
    testBox.textContent = "Unable to load the API response.";
    console.error(error);
  }
});
