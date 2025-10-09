# SCHNELL-DEBUG: Canvas Klickbarkeit

## SOFORT IM BROWSER AUSFÜHREN:

### 1. Canvas Status komplett ausgeben:
```javascript
const canvas = document.querySelector('canvas');
console.log('=== CANVAS STATUS ===');
console.log('Canvas gefunden:', !!canvas);
console.log('pointer-events:', canvas.style.pointerEvents);
console.log('computed pointer-events:', window.getComputedStyle(canvas).pointerEvents);
console.log('Canvas Position:', canvas.getBoundingClientRect());
console.log('Canvas z-index:', window.getComputedStyle(canvas).zIndex);
console.log('Active Element:', document.activeElement);
console.log('Canvas hat Focus:', document.activeElement === canvas);
```

### 2. SOFORT-FIX 1: Canvas wieder aktivieren (für Godot UI):
```javascript
const canvas = document.querySelector('canvas');
canvas.style.pointerEvents = 'auto';
canvas.focus();
console.log('✅ Canvas aktiviert und fokussiert');
// JETZT TESTEN!
```

### 3. Falls immer noch nicht klickbar - HTML Elemente prüfen:
```javascript
console.log('=== HTML ELEMENTE ===');
console.log('Buttons:', document.querySelectorAll('button').length);
console.log('Inputs:', document.querySelectorAll('input').length);
console.log('Alle Elemente:', document.querySelectorAll('*').length);

// Zeige alle sichtbaren interaktiven Elemente
document.querySelectorAll('button, input, a, [onclick]').forEach((el, i) => {
    const rect = el.getBoundingClientRect();
    console.log(`Element ${i}:`, {
        tag: el.tagName,
        visible: el.offsetParent !== null,
        position: rect,
        zIndex: window.getComputedStyle(el).zIndex
    });
});
```

### 4. Click-Tracking aktivieren:
```javascript
document.addEventListener('click', (e) => {
    console.log('🖱️ CLICK:', {
        x: e.clientX,
        y: e.clientY,
        target: e.target.tagName,
        element: e.target
    });
}, { capture: true });

document.addEventListener('mousedown', (e) => {
    console.log('🖱️ MOUSEDOWN:', {
        x: e.clientX,
        y: e.clientY,
        target: e.target.tagName
    });
}, { capture: true });

console.log('✅ Event-Tracking aktiv - klicke jetzt irgendwo!');
```

### 5. Canvas Event-Handling testen:
```javascript
const canvas = document.querySelector('canvas');

canvas.addEventListener('click', (e) => {
    console.log('🎨 Canvas CLICK:', e);
}, { capture: true });

canvas.addEventListener('mousedown', (e) => {
    console.log('🎨 Canvas MOUSEDOWN:', e);
}, { capture: true });

console.log('✅ Canvas Event-Listener aktiv');
```

---

## BITTE FÜHRE AUS UND SCHICKE MIR:

1. **Alle Console-Outputs** von oben
2. **Was passiert wenn du klickst?** (Werden Events getrackt?)
3. **Wie viele HTML-Elemente gibt es?** (Buttons/Inputs)

Das hilft mir zu verstehen ob:
- Godot UI im Canvas ist (keine HTML-Elemente)
- Canvas Focus das Problem ist
- Anderes Element Events abfängt
