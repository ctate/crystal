const numStars = 1000; // Anzahl der Sterne
const starField = document.querySelector(".star-field");
const totalAnimationDuration = 10; // Gesamtanimationdauer in Sekunden

// Erstellen der Sterne
for (let i = 0; i < numStars; i++) {
  const star = document.createElement("div");
  star.classList.add("star");
  star.style.left = `${Math.random() * 100}%`;
  star.style.top = `${Math.random() * 100}%`;

  // Zufällige Opazität zwischen 0 und 1 für jeden Stern
  star.style.opacity = Math.random();

  // Zufällige Auswahl der Farbe für 20% der Sterne
  if (Math.random() < 0.1) {
    star.classList.add("colored-star");
    const colors = ["yellow", "blue", "green", "purple", "pink"];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];
    star.style.backgroundColor = randomColor;
  }

  // Zufällige Animationdauer zwischen 1 und 4 Sekunden für jeden Stern
  star.style.animationDuration = `${Math.random() * 3 + 1}s`;

  // Zufällige Verzögerung zwischen 0 und 10 Sekunden für jeden Stern
  star.style.animationDelay = `${Math.random() * totalAnimationDuration}s`;

  starField.appendChild(star);
}