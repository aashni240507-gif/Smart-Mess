/**
 * SmartMess Application JavaScript
 * Handles interactive UI behaviors, live calculations, star ratings, and chart visualizations.
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Sidebar Toggle for Mobile Devices
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar');
    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('show');
        });
    }

    // 2. Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            if (bsAlert) bsAlert.close();
        }, 5000);
    });

    // 3. Interactive Star Ratings for Feedback Form
    initStarRatings();

    // 4. Live Food Wastage Calculator
    initWastageCalculator();
});

/**
 * Star rating selector logic
 */
function initStarRatings() {
    const starContainers = document.querySelectorAll('.star-rating');
    starContainers.forEach(function (container) {
        const inputId = container.getAttribute('data-input-id');
        const input = document.getElementById(inputId);
        const stars = container.querySelectorAll('.star');

        if (!input) return;

        stars.forEach(function (star, index) {
            star.addEventListener('mouseenter', function () {
                highlightStars(stars, index + 1);
            });

            star.addEventListener('mouseleave', function () {
                const currentVal = parseInt(input.value) || 0;
                highlightStars(stars, currentVal);
            });

            star.addEventListener('click', function () {
                const rating = index + 1;
                input.value = rating;
                highlightStars(stars, rating);
            });
        });

        // Initialize display if default value exists
        const initialVal = parseInt(input.value) || 0;
        if (initialVal > 0) {
            highlightStars(stars, initialVal);
        }
    });
}

function highlightStars(stars, count) {
    stars.forEach(function (star, idx) {
        if (idx < count) {
            star.classList.add('selected');
        } else {
            star.classList.remove('selected');
        }
    });
}

/**
 * Dynamic calculation of food wastage percentage and client validations
 */
function initWastageCalculator() {
    const prepInput = document.getElementById('foodPrepared');
    const servedInput = document.getElementById('foodServed');
    const wastedInput = document.getElementById('foodWasted');
    const pctDisplay = document.getElementById('wastagePctDisplay');

    if (!prepInput || !wastedInput) return;

    function calculate() {
        const prep = parseFloat(prepInput.value) || 0;
        const wasted = parseFloat(wastedInput.value) || 0;
        const served = servedInput ? (parseFloat(servedInput.value) || 0) : 0;

        if (prep > 0) {
            const pct = ((wasted / prep) * 100).toFixed(2);
            if (pctDisplay) {
                pctDisplay.textContent = pct + '%';
                if (pct > 15) {
                    pctDisplay.className = 'text-danger fw-bold';
                } else if (pct > 8) {
                    pctDisplay.className = 'text-warning fw-bold';
                } else {
                    pctDisplay.className = 'text-success fw-bold';
                }
            }
        } else if (pctDisplay) {
            pctDisplay.textContent = '0.00%';
            pctDisplay.className = 'text-muted';
        }
    }

    prepInput.addEventListener('input', calculate);
    wastedInput.addEventListener('input', calculate);
    if (servedInput) servedInput.addEventListener('input', calculate);
}

/**
 * 1-Click Demo Login autofill helper
 */
function fillDemoCredentials(email, password) {
    const emailField = document.getElementById('loginEmail');
    const passwordField = document.getElementById('loginPassword');
    if (emailField && passwordField) {
        emailField.value = email;
        passwordField.value = password;
        // Visual highlight
        emailField.classList.add('is-valid');
        passwordField.classList.add('is-valid');
    }
}
