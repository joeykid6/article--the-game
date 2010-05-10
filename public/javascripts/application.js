// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


/*
 * Effect interrupt problems with this solution,
 * so we should try livepipe's fully customized scrollbar instead.
 * Save it in case livepipe solution doesn't work. */
document.observe("dom:loaded", function() {
    Event.observe($('dialogue_window'), 'click', function() { Effect.Queues.get('dialogue').invoke('cancel'); })
    Event.observe($('dialogue_window'), 'mouseenter', function() { Effect.Queues.get('dialogue').invoke('cancel'); })
    Event.observe($('dialogue_window'), 'mouseleave', function() { Effect.Queues.get('dialogue').invoke('cancel'); })
    Event.observe($('dialogue_window'), 'mousewheel', function() { Effect.Queues.get('dialogue').invoke('cancel'); })
    Event.observe($('dialogue_window'), 'DOMMouseScroll', function() { Effect.Queues.get('dialogue').invoke('cancel'); })
});

