<%--
use https://www.toptal.com/developers/javascript-minifier to minify ApplyJS.js
then check the $ID and $IsFlush variables and change them back
--%>



(()=>{let e=new URLSearchParams(window.location.search),a=e.has("flush")||'$IsFlush' === 'true',t="SiteWideUniversalData";a&&localStorage.removeItem(t);let s=()=>{try{let e=localStorage.getItem(t);if(e){let{data:a,timestamp:s}=JSON.parse(e);if(Date.now()-s<36e5)return a}}catch{}},i=e=>{localStorage.setItem(t,JSON.stringify({data:e,timestamp:Date.now()}))},r=async e=>{if(!e)throw Error("Page ID is required");let a=s(),t="query{ ",r=`(pageId: ${e}) `,n=void 0===a?t+"siteWideUniversalData"+r+" siteWidePersonalisedData"+r+" } ":t+"siteWidePersonalisedData"+r+" } ";return fetch("/graphql-site-wide-data",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({query:n})}).then(e=>e.json()).then(e=>(void 0===a&&e.data.siteWideUniversalData&&i(a=e.data.siteWideUniversalData),{universal:a,personalised:e.data.siteWidePersonalisedData}))},n=(e,a,t=!1)=>{requestAnimationFrame(()=>{document.querySelectorAll(e).forEach(e=>{a.class&&!e.classList.contains(a.class)&&e.classList.add(a.class),a.html&&e.innerHTML!==a.html&&(e.innerHTML=a.html),t&&a.callback&&a.callback(e)})})},l=s();l&&Object.entries(l).forEach(([e,a])=>{n(e,a)}),(async()=>{let{universal:e,personalised:a}=await r("$ID");!l&&e&&Object.entries(e).forEach(([e,a])=>{n(e,a)}),a&&Object.entries(a).forEach(([e,a])=>{n(e,a,!0)})})()})();
