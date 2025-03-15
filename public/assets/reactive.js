document.querySelectorAll('[reactive\\:snapshot]').forEach(el => {
    el.__reactive = JSON.parse(el.getAttribute('reactive:snapshot'));
    // el.removeAttribute('reactive:snapshot')

    initReactiveClick(el);
    initReactiveModel(el);
    initReactiveModelLazy(el);
});

function sendRequest(el, addToPayload) {
    let snapshot = el.__reactive;

    fetch('/reactive', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        },
        body: JSON.stringify({
            snapshot,
            ...addToPayload,
        }),
    })
    .then(response => response.json())
    .then(response => {
        let {html, snapshot} = response;

        el.__reactive = snapshot;

        Alpine.morph(el.firstElementChild, html)

        updateReactiveModelInputs(el)
    });
}

function updateReactiveModelInputs(rootElement) {
    let data = rootElement.__reactive.data;

    rootElement.querySelectorAll('[reactive\\:model]').forEach(el => {
        let property = el.getAttribute('reactive:model')

        el.value = data[property]
    })
}

function initReactiveClick(rootElement) {
    rootElement.addEventListener('click', e => {
        if (! e.target.hasAttribute('reactive:click')) return;

        let method = e.target.getAttribute('reactive:click');

        sendRequest(rootElement, {callMethod: method});
    })
}

function initReactiveModel(rootElement) {
    let data = rootElement.__reactive.data;

    updateReactiveModelInputs(rootElement)

    rootElement.addEventListener('input', e => {
        if (! e.target.hasAttribute('reactive:model')) return;

        let property = e.target.getAttribute('reactive:model');
        let value = e.target.value;

        sendRequest(rootElement, {
            updateProperty: [property, value],
        });
    })
}

function initReactiveModelLazy(rootElement) {
    let data = rootElement.__reactive.data;

    updateReactiveModelInputs(rootElement)

    rootElement.addEventListener('change', e => {
        if (! e.target.hasAttribute('reactive:model.lazy')) return;

        let property = e.target.getAttribute('reactive:model.lazy');
        let value = e.target.value;

        sendRequest(rootElement, {
            updateProperty: [property, value],
        });
    })
}
