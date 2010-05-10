
/* An extension of Scriptaculous which scrolls
 * any container element to an arbitrary X and Y position
 *
 * Included from http://pastie.org/36461
 * Added to_element: option to scroll to specific element
 *
 * Currently having problems with scrollbar stop during effect; so will try livepipe
 * scrollbar instead */
Effect.Scroll = Class.create();
Object.extend(Object.extend(Effect.Scroll.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    var options = Object.extend({
      x:    0,
      y:    0,
      to_bottom: null,
      mode: 'absolute'
    } , arguments[1] || {}  );
    this.start(options);
  },
  setup: function() {
    if (this.options.continuous && !this.element._ext ) {
      this.element.cleanWhitespace();
      this.element._ext=true;
      this.element.appendChild(this.element.firstChild);
    }

    this.originalLeft=this.element.scrollLeft;
    this.originalTop=this.element.scrollTop;

    if (this.options.to_bottom) {
      this.options.y = this.element.scrollHeight;
    }
    
    if(this.options.mode == 'absolute') {
      this.options.x -= this.originalLeft;
      this.options.y -= this.originalTop;
    } else {

    }
  },
  update: function(position) {
    this.element.scrollLeft = this.options.x * position + this.originalLeft;
    this.element.scrollTop  = this.options.y * position + this.originalTop;
  }
});
