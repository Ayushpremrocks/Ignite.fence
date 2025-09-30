// Top navbar navigation for landing page
// Supports both data-page links and regular hash links (href="#section")
document.querySelectorAll('.topnav a').forEach(link => {
  const isDataPage = link.hasAttribute('data-page');
  const href = link.getAttribute('href') || '';

  if (isDataPage || href.startsWith('#')) {
    link.addEventListener('click', e => {
      e.preventDefault();

      // Remove active class from all links
      document.querySelectorAll('.topnav a').forEach(a => a.classList.remove('active'));
      link.classList.add('active');

      // Hide all pages
      document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));

      // Determine target section ID
      const pageId = isDataPage ? link.getAttribute('data-page') : href.replace('#', '');
      const target = pageId ? document.getElementById(pageId) : null;
      if (target) target.classList.add('active');

      // Optionally scroll into view for smooth UX
      if (target && typeof target.scrollIntoView === 'function') {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  }
});


// =======================
// FAQ Dropdown Accordion
// =======================
document.querySelectorAll(".faq-question").forEach((btn) => {
  btn.addEventListener("click", () => {
    const answer = btn.nextElementSibling;

    // toggle dropdown
    answer.classList.toggle("open");

    // close others
    document.querySelectorAll(".faq-answer").forEach((other) => {
      if (other !== answer) other.classList.remove("open");
    });
  });
});
