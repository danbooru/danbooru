const mixpanelInit = (user_id, session_id, opt_out, user_data) => {
  if (typeof window.mixpanel !== "object") {
    return;
  }

  if (user_id) {
    window.mixpanel.identify(user_id);

    if (opt_out) {
      window.mixpanel.opt_out_tracking();
    } else {
      window.mixpanel.people.set(user_data);
    }
  } else if (session_id) {
    window.mixpanel.identify("anon:" + session_id);
  }
}

const mixpanelEvent = (title, props) => {
  if (typeof window.mixpanel !== "object") {
    return;
  }

  window.mixpanel.track(title, props);
}

export { mixpanelInit, mixpanelEvent };
