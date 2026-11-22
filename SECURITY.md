# Security Policy

## Reporting a Vulnerability

If you find a security issue that is immediately exploitable and should be kept private until it's fixed, report it by
opening a private security advisory on GitHub:

https://github.com/danbooru/danbooru/security/advisories/new

Otherwise, for lower-risk or more general issues that don't need to be kept private, you can open a normal issue at:

https://github.com/danbooru/danbooru/issues/new

## Guidelines

* **One issue per report.** Report each bug separately. Don't bundle multiple unrelated issues into a single report. See below for security audits done with AI agents.
* **Include a proof of concept or steps to reproduce.** Show how to trigger the bug and what the impact is. Include example URLs where possible.
* **Use testbooru for testing.** Don't use the main site for testing or demonstrating bugs. You can use https://testbooru.donmai.us for demonstrating low-severity issues (not code execution or stealing other users' data), or a personal dev instance otherwise. See [docs/README.md](docs/README.md) for how to set one up.

## Audits with AI agents

If you audit Danbooru with an AI agent, have the agent triage its findings and format them as described below before
you report them. Tell it to read this file and follow the instructions.

**Triage the findings first:**

* **Verify each finding against the code.** Reproduce it if you can, with a request, a test, or `bin/rails runner`.
  Agents often report things that turn out to be fine, or mix a real bug with a wrong claim. Check each part of a
  finding separately, and drop the parts that turned out to be wrong.
* **Look for similar bugs.** For each confirmed finding, check whether the same mistake is in other places, and list
  them.
* **Find the commit that introduced the bug**, when there is one, with `git log -S`.

**Then report them**, preferably as one issue or advisory per finding, otherwise as a single report with all the findings, each
separated by a `---` line. At the top of a single report, say which commit was audited and which model did the audit.

Format each finding like this, leaving out sections that don't apply:

```markdown
## Short description of the problem

- Status: confirmed or unconfirmed
- Severity: critical, high, or low
- Category: XSS, DoS, Info leak, Authorization, Authentication, Abuse, Race condition, Infrastructure, or Hardening

One or two sentences on who can do what, in plain words, without code.

**Impact**
- How serious it is: the realistic damage, and how likely or practical an attack is.

**Repro**
- Steps or requests that show the bug.

**Cause**
- Where in the code it goes wrong, briefly, and the commit that introduced it, if known.

**Also affected**
- Other places with the same bug, which should be fixed along with this one.

**Fix**
- The fix in a line or two. Not a full plan.
```

* **Status:** `confirmed` if you reproduced it or it's clearly real from the code. `unconfirmed` if you couldn't tell.
* **Severity:**
  * `critical`: easy to exploit, with serious impact. RCE, stored XSS, SQL injection, or a DoS that exhausts CPU or memory.
  * `high`: self-XSS, a leak of highly sensitive data, or a DoS that ties up threads or workers.
  * `low`: a leak of not very sensitive data, a minor DoS, or anything else.
* **Start with the impact.** Say who can do it (anonymous users, any member, moderators) and what they get. Put method
  names and code in the sections below.
* **Make repros concrete.** Use real endpoints and parameters, explain placeholders like `<post id>`, and define any
  variables used in code snippets.
* **Link code to GitHub.** Link files and methods to the lines on GitHub, using a permalink to the commit that was
  audited (e.g. `https://github.com/danbooru/danbooru/blob/<full sha>/app/models/post.rb#L1635-L1639`).
* **Put each heading on its own line, followed by bullet points.**
* **Only link to things we can open.** Don't refer to local files or notes.
* **One problem per finding.** Split unrelated problems into separate findings.
