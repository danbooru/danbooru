import { splitWords } from './utility';
import Cookie from './cookie';

// A blacklist represents a set of blacklist rules that match against a set of posts.
class Blacklist {
  // @param {HTMLElement} root - The root DOM element that contains the blacklist controls.
  constructor(root) {
    this.root = root;
    this.rules = [];
    this.posts = [];
  }

  // @param {Array<String>} rules - The list of blacklist rules.
  initialize(rules) {
    // Attach the blacklist instance to the root DOM element for access with `$("#blacklist-box").get(0).blacklist`
    this.root.blacklist = this;

    this.rules = rules.map(rule => new Rule(this, rule));
    this.posts = $(".post-preview, .image-container, #c-comments .post, .mod-queue-preview.post-preview").toArray().map(post => new Post(post, this));
    this.apply();
    this.cleanupStorage();

    this.showAll = JSON.parse(localStorage.getItem(`blacklist.showAll`)) ?? false;
    this.autocollapse = JSON.parse(localStorage.getItem(`blacklist.autocollapse`)) ?? true;
    this.collapsed = JSON.parse(localStorage.getItem(`blacklist.collapsed`)) ?? this.enabled; // This comes last because it depends on blacklists being applied first.
  }

  // Apply all blacklist rules to all posts.
  apply() {
    this.posts.forEach(post => post.applyRules());
  }

  get enabled() {
    return this.visibleRules.every(rule => rule.enabled);
  }

  set enabled(value) {
    if (this.autocollapse) {
      this.collapsed = value;
    }

    this.visibleRules.forEach(rule => rule.enabled = Boolean(value));
    this.posts.forEach(post => post.update());
  }

  // @returns {Boolean} - True if some but not all rules are enabled.
  get partiallyEnabled() {
    return this.visibleRules.some(rule => rule.enabled) && !this.visibleRules.every(rule => rule.enabled);
  }

  get showAll() {
    return this._showAll;
  }

  set showAll(value) {
    this._showAll = Boolean(value);
    localStorage.setItem(`blacklist.showAll`, JSON.stringify(value));
  }

  get blurImages() {
    return this.rules.some(rule => rule.hideMethod === "blur");
  }

  set blurImages(value) {
    this.rules.forEach(rule => rule.hideMethod = Boolean(value) ? "blur" : "hide");
  }

  get collapsed() {
    return this._collapsed;
  }

  set collapsed(value) {
    this._collapsed = Boolean(value);
    localStorage.setItem(`blacklist.collapsed`, JSON.stringify(value));
  }

  get autocollapse() {
    return this._autocollapse;
  }

  set autocollapse(value) {
    this._autocollapse = Boolean(value);
    localStorage.setItem(`blacklist.autocollapse`, JSON.stringify(value));
  }

  // @returns {Boolean} - True if the blacklist box should be visible, i.e. if there are any visible rules.
  get visible() {
    return this.visibleRules.length > 0;
  }

  // @returns {Array<Rule>} - The set of rules that are currently visible (all rules if showAll is enabled, or only rules matching a post if not).
  get visibleRules() {
    return this.rules.filter(rule => rule.visible);
  }

  // @returns {Array<Post>} - The set of posts that are currently blacklisted by at least one rule.
  get blacklistedPosts() {
    return this.posts.filter(post => post.blacklisted);
  }

  // Remove from storage any rules that have been removed from the blacklist.
  cleanupStorage() {
    Cookie.remove("dab");
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith("blacklist.enabled:") && !this.rules.some(rule => key === `blacklist.enabled:${rule.string}`)) {
        localStorage.removeItem(key);
      }
    });
  }
}

// A post holds the set of blacklist rules that match the post. The post is blacklisted if any of the matching rules are enabled.
class Post {
  // @param {HTMLElement} post - The DOM element representing the post.
  // @param {Blacklist} blacklist - The blacklist that this post belongs to.
  constructor(post, blacklist) {
    this.post = post;
    this.blacklist = blacklist;
    this.rules = new Set();

    this.post.classList.add("blacklist-initialized");
    this.post.post = Alpine.reactive(this); // Attach the post object to the DOM element for access with `$("#post_123").get(0).post`
  }

  // Re-apply all blacklist rules on the post when a rule or the post changes.
  applyRules() {
    this.score = parseInt(this.post.getAttribute("data-score"));
    this.tags = new Set([
      ...splitWords(this.post.getAttribute("data-tags")),
      ...splitWords(this.post.getAttribute("data-flags")).map(s => `status:${s}`),
      `rating:${this.post.getAttribute("data-rating")}`,
      `uploaderid:${this.post.getAttribute("data-uploader-id")}`,
    ]);

    this.blacklist.rules.forEach(rule => rule.apply(this));
  }

  // @returns {Boolean} - True if the post is blacklisted, i.e. at least one rule matches the post and is enabled.
  get blacklisted() {
    return [...this.rules].some(rule => rule.enabled);
  }

  // Update the post when a blacklist rule is matched or toggled.
  update() {
    if (this.blacklisted) {
      this.hide();
    } else {
      this.show();
    }
  }

  get blacklistClass() {
    return Array.from(this.rules).some(rule => rule.hideMethod === "hide") ? "blacklisted-hidden" : "blacklisted-blurred";
  }

  // Hide the post when it's blacklisted.
  hide() {
    this.post.classList.remove("blacklisted-hidden", "blacklisted-blurred");
    this.post.classList.add("blacklist-initialized", "blacklisted-active", this.blacklistClass);

    let video = this.post.querySelector("video#image");
    if (video) {
      video.pause();
      video.currentTime = 0;
    }
  }

  // Unhide the post when it's not blacklisted.
  show() {
    this.post.classList.remove("blacklisted-active", "blacklisted-hidden", "blacklisted-blurred");
    this.post.classList.add("blacklist-initialized");

    let video = this.post.querySelector("video#image");
    if (video) {
      video.play();
    }
  }
}

// A rule represents a single line in a user's blacklist. It contains the set of posts that match the rule, and the tags
// that the rule requires, excludes, or optionally matches.
class Rule {
  // @param {Blacklist} blacklist - The blacklist that this rule belongs to.
  // @param {String} string - The rule string.
  constructor(blacklist, string) {
    this.blacklist = blacklist;
    this.string = string;
    this.tags = splitWords(string);
    this.require = [];
    this.exclude = [];
    this.optional = [];
    this.posts = new Set();
    this.min_score = null;

    this.tags.forEach(tag => {
      if (tag.charAt(0) === '-') {
        this.exclude.push(tag.slice(1));
      } else if (tag.charAt(0) === '~') {
        this.optional.push(tag.slice(1));
      } else if (tag.match(/^score:<.+/)) {
        var score = tag.match(/^score:<(.+)/)[1];
        this.min_score = parseInt(score);
      } else {
        this.require.push(tag);
      }
    });
  }

  // A rule is visible if all rules are visible or if it matches at least one post, regardless of whether the rule is enabled or not.
  get visible() {
    return this.blacklist.showAll || this.posts.size > 0;
  }

  get enabled() {
    return JSON.parse(localStorage.getItem(`blacklist.enabled:${this.string}`)) ?? true;
  }

  set enabled(value) {
    localStorage.setItem(`blacklist.enabled:${this.string}`, JSON.stringify(value));
    this.posts.forEach(post => post.update());
  }

  get hideMethod() {
    return JSON.parse(localStorage.getItem(`blacklist.hideMethod:${this.string}`)) ?? "hide";
  }

  set hideMethod(value) {
    localStorage.setItem(`blacklist.hideMethod:${this.string}`, JSON.stringify(value));
    this.posts.forEach(post => post.update());
  }

  toggle() {
    this.enabled = !this.enabled;
  }

  // @param {Post} post - The post to check against this rule.
  // @returns {Boolean} - True if the rule matches the post.
  match(post) {
    let score_test = this.min_score === null || post.score < this.min_score;

    return (this.require.every(tag => post.tags.has(tag)) && score_test)
      && (this.optional.length === 0 || this.optional.some(tag => post.tags.has(tag)))
      && !this.exclude.some(tag => post.tags.has(tag));
  }

  // Apply this rule to a single post.
  apply(post) {
    if (this.match(post)) {
      this.posts.add(post);
      post.rules.add(this);
    } else {
      this.posts.delete(post);
      post.rules.delete(this);
    }

    post.update();
  }
}

Blacklist.Post = Post;
Blacklist.Rule = Rule;

export default Blacklist;
