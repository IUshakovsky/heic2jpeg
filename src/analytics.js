const GA_MEASUREMENT_ID = process.env.VUE_APP_GA_MEASUREMENT_ID;
(function() {
  const script = document.createElement('script');
  script.setAttribute('async', '');
  script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`;
  document.head.appendChild(script);
})();
window.dataLayer = window.dataLayer || [];
function gtag(){window.dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', GA_MEASUREMENT_ID, { 'page_path': '/' });
