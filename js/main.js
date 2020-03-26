document.addEventListener('change', function (event) {
    if (!event.target.matches('[data-font-trial] [type="radio"][data-font-size]')) {
        return;
    }
    if (!event.target.checked) {
        return;
    }
    var parent = event.target.closest('[data-font-trial]');
    var value = event.target.value;
    var textareas = parent.querySelectorAll('[data-font-trial-text]');
    var fontSize = '100%';
    switch (value) {
    case 'small':
        fontSize = '100%';
        break;
    case 'medium':
        fontSize = '200%';
        break;
    case 'large':
        fontSize = '400%';
        break;
    }
    Array.from(textareas).forEach(function (textarea) {
        textarea.style.fontSize = fontSize;
    });
    event.preventDefault();
});
