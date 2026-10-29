window.onload = () => {
  const test_box = document.getElementById("testing")
  const body = {
    message: "This is a test",
  }
  fetch("/api/test", { method: "post", body: body }).then((r) => {
    r.json().then((d) => {
      test_box.innerHTML = d.message
    })
  })
}
