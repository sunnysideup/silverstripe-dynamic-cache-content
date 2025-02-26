;(() => {
    const UNIVERSAL_STORAGE_KEY = 'SiteWideUniversalData'
    const ONE_HOUR = 60 * 60 * 1000

    function getCachedUniversalData () {
        try {
            const stored = localStorage.getItem(UNIVERSAL_STORAGE_KEY)
            if (stored) {
                const { data, timestamp } = JSON.parse(stored)
                if (Date.now() - timestamp < ONE_HOUR) return data
            }
        } catch {}
        return undefined
    }

    function setCachedUniversalData (data) {
        localStorage.setItem(
            UNIVERSAL_STORAGE_KEY,
            JSON.stringify({ data, timestamp: Date.now() })
        )
    }

    async function fetchSiteWideData (pageId) {
        if (!pageId) throw new Error('Page ID is required')

        let universalData = getCachedUniversalData()
        const queryStart = 'query{ '
        const pageIdString = `(pageId: ${pageId}) `
        const queryEnd = ' } '
        const query =
            universalData === undefined
                ? queryStart +
                  'siteWideUniversalData' +
                  pageIdString +
                  ' siteWidePersonalisedData' +
                  pageIdString +
                  queryEnd
                : queryStart +
                  'siteWidePersonalisedData' +
                  pageIdString +
                  queryEnd

        return fetch('/graphql-site-wide-data', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query })
        })
            .then(response => response.json())
            .then(result => {
                if (
                    universalData === undefined &&
                    result.data.siteWideUniversalData
                ) {
                    universalData = result.data.siteWideUniversalData
                    setCachedUniversalData(universalData)
                }
                return {
                    universal: universalData,
                    personalised: result.data.siteWidePersonalisedData
                }
            })
    }

    function applyData (selector, values, runCallback = false) {
        requestIdleCallback(() => {
            document.querySelectorAll(selector).forEach(el => {
                if (values.class && !el.classList.contains(values.class)) {
                    el.classList.add(values.class)
                }
                if (values.html && el.innerHTML !== values.html) {
                    el.innerHTML = values.html
                }
                if (runCallback && values.callback) {
                    values.callback(el)
                }
            })
        })
    }

    // Fetch data as soon as possible without blocking rendering
    const cachedUniversal = getCachedUniversalData()
    if (cachedUniversal) {
        Object.entries(cachedUniversal).forEach(([selector, values]) => {
            applyData(selector, values)
        })
    }

    // Start fetching site-wide data immediately without blocking rendering
    const siteWideDataPromise = new Promise(resolve => {
        setTimeout(() => {
            fetchSiteWideData('$ID').then(resolve)
        }, 0)
    })

    // Wait for DOMContentLoaded to apply personalized data
    document.addEventListener('DOMContentLoaded', async () => {
        const { universal, personalised } = await siteWideDataPromise

        if (!cachedUniversal && universal) {
            Object.entries(universal).forEach(([selector, values]) => {
                applyData(selector, values)
            })
        }

        if (personalised) {
            Object.entries(personalised).forEach(([selector, values]) => {
                applyData(selector, values, true)
            })
        }
    })
})()
