;(() => {
    const UNIVERSAL_STORAGE_KEY = 'SiteWideUniversalData'
    const ONE_HOUR = 0

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

        // Build a query that always declares $pageId and passes it to both fields.
        // If universal data is cached, only fetch personalised data.
        const queryStart = 'query{ '
        const pageIdString = '(pageId: ' + pageId + ') '
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
                  ' siteWidePersonalisedData' +
                  pageIdString +
                  queryEnd
        console.log(query)
        const response = await fetch('/graphql-site-wide-data', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query })
        })
        const result = await response.json()

        if (universalData === undefined && result.data.siteWideUniversalData) {
            universalData = result.data.siteWideUniversalData
            setCachedUniversalData(universalData)
        }
        const personalisedData = result.data.siteWidePersonalisedData
        return { universal: universalData, personalised: personalisedData }
    }

    const callbacks = {}
    function applyData (selector, values, runCallback = false) {
        document.querySelectorAll(selector).forEach(el => {
            if (values.class && !el.classList.contains(values.class)) {
                el.classList.add(values.class)
            }
            if (values.html && el.innerHTML !== values.html) {
                el.innerHTML = values.html
            }
            if (runCallback && values.callback) {
                callbacks[selector] = values.callback
            }
        })
    }

    // Start fetching data immediately (before the page loads)
    const siteWideDataPromise = fetchSiteWideData('$ID')

    document.addEventListener('DOMContentLoaded', async () => {
        // Apply cached universal data immediately if available
        const cachedUniversal = getCachedUniversalData()
        console.log(cachedUniversal)
        if (cachedUniversal) {
            Object.entries(cachedUniversal).forEach(([selector, values]) => {
                applyData(selector, values)
            })
        }
        // Wait for the fetched data (this may already be resolved)
        const { universal, personalised } = await siteWideDataPromise
        // If universal data wasn't cached, apply it now
        if (!cachedUniversal && universal) {
            Object.entries(universal).forEach(([selector, values]) => {
                applyData(selector, values)
            })
        }
        // Always apply personalised data after fetch
        if (personalised) {
            Object.entries(personalised).forEach(([selector, values]) => {
                applyData(selector, values, true)
            })
        }
        // Execute any callbacks collected during applyData calls
        Object.entries(callbacks).forEach(([selector, callback]) => {
            callback(document.querySelectorAll(selector))
        })
    })
})()
