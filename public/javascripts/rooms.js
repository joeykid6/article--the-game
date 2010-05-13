/*
 * Code for livepipe scrollbar
 */
document.observe("dom:loaded", function() {
   dialogue_scrollbar = new Control.ScrollBar('dialogue_window_content', 'scrollbar_track', {scroll_to_steps: 150});
});
