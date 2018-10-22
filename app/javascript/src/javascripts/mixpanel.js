const mixpanelInit = (user_id, opt_out, user_data) => {
  if (typeof window.mixpanel !== "object") {
    return;
  }

  window.mixpanel.identify(user_id);

  if (opt_out) {
    window.mixpanel.opt_out_tracking();
  } else {
    window.mixpanel.people.set(user_data);
  }
}

const mixpanelEvent = (title, props) => {
  if (typeof window.mixpanel !== "object") {
    return;
  }

  window.mixpanel.track(title, props);
}

const mixpanelAlias = (user_id) => {
  if (typeof window.mixpanel !== "object") {
    return;
  }

  window.mixpanel.alias(user_id);
}

export { mixpanelInit, mixpanelEvent, mixpanelAlias };
