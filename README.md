# AI Coding Workshop

---

## Instructions for participants

Welcome! There are **three setup steps**. If you are stuck at any, please raise your hand.

---

### Step 1: Open the codespace

1. Click the badge below. Ctrl + click to open in a new window.

   <a href="https://codespaces.new/msblei/AI_coding_workshop?quickstart=1" target="_blank">
     <img src="https://github.com/codespaces/badge.svg" alt="Open in GitHub Codespaces">
   </a>

2. Sign in to GitHub if asked. On the next page, click **"Create new codespace"**.

   ![Create codespace button](resources/create_codespace.png)

3. **Wait up to 5 minutes** for setup to finish. You'll know it's done when a welcome banner appears in the **terminal at the bottom of the screen**.

   ![Welcome banner in the terminal](resources/welcome_screen.png)

---

### Step 2: Set up your AI coding assistant

1. Open the workshop document:

   **[Workshop document](https://docs.google.com/document/d/1cgWG_Foie4dn7LOJ9J-9Qep2sB2R1cD0maejTJbVMjY/edit?usp=sharing)**

2. Find the row with your name in the document.
   - **Paste your app URL** (from the welcome banner in step 1) into your row.
   - Leave the document open as you will need to copy both the Base URL and the API key later on.

   ![Workshop document with names, keys, and URLs](resources/google_document.png)

3. Back in the codespace, click the **robot icon** on the left sidebar. A panel opens.

   ![Cline icon in the sidebar](resources/cline_icon.png)

   Select "Bring my own API Key"

   ![Select bring your own key for Cline](resources/cline_bring_your_own_key.png)

   Add the following information:

   API Provider: `OpenAI Compatible`

   Base URL: From the Google Doc before

   OpenAI Compatible API Key: From the Google Doc before

   Model ID: `gpt-5.4`

   ![Paste the API key into Cline](resources/cline_configuration.png)

   Click "Continue".

4. In the Cline chat box, send any message:

   E.g.

   > Hello! Say hi back so I know you're working.

5. Wait a few seconds for Cline to reply.

   ![Cline replying to the test message](resources/cline_success.png)

---

### Step 3: Start the app

1. Switch to the terminal in the bottom again.

2. In the terminal, type the following and press Enter:

   ```
   npm start
   ```

3. Wait until you see **"Compiled successfully!"** below it — about 30 seconds.

4. Click your app URL (or copy-paste it into a new browser tab). The page should say **"Everything works!"**.

5. Wait for further instructions.

---

---

## Instructions for instructors

Everything below this line is for the people running the workshop.

### Workshop flow (120 min)

| Block                       | Time    | Activity                                                                                                                                                                                                                                                                       |
| --------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **A. Setup**                | 0–15    | "Click the badge" slide. Participants work through the three checkpoint steps in the README. Everyone arrives at Checkpoint 3 ("Everything works!") before moving on.                                                                                                          |
| **B. Vibe round**           | 15–45   | Slide intro to Cline's Plan/Act toggle (set to **Act** for this round). Hand out Exercise 1 prompt — see below. Participants iterate freely. Expected: messy half-working apps.                                                                                                |
| **C. Showcase + diagnosis** | 45–60   | Click through 5–8 submissions live (from the workshop doc's URL column). Discussion: "What's broken? Why?" Land the takeaway: vibe coding produces _something_ but structure rots fast as features pile on.                                                                    |
| **D. Spec-driven intro**    | 60–75   | Slide + live demo. Either spin up a fresh Codespace or have participants run `npm run reset-app`. Switch Cline to **Plan mode**. Run the Exercise 2 spec prompt. Narrate: "no code yet, just a plan we can argue with." Refine the plan with 2–3 follow-ups. Then flip to Act. |
| **E. Build round**          | 75–110  | Participants run their own plan→act cycle. Float around.                                                                                                                                                                                                                       |
| **F. Showcase + wrap**      | 110–120 | Click through again. Side-by-side: vibe round vs spec round. Q&A.                                                                                                                                                                                                              |

### Exercise 1 prompt (Act mode, on slide)

> Build me a flashcard study app in this React project. I should be able to flip cards and go to the next one.

This intentionally yields _something_. Failure modes participants discover fast: no add/edit, no persistence, no "got it / review again", one deck only, no progress indicator. Use those failures as the motivation for Exercise 2.

### Exercise 2 prompt (Plan mode, hand out after the spec-driven intro)

> I want a flashcard study app. Users create multiple decks, each with cards (front/back text). In study mode, they review a deck one card at a time, flip to see the answer, then mark "got it" or "review again". Cards marked "review again" come back in the same session. Everything persists in localStorage. Single-page React app, no backend.
>
> Before writing any code:
>
> 1. Write `architecture.md` covering the data model (TypeScript-style interfaces), the component tree, the state-flow between screens, and the localStorage schema. Use Mermaid diagrams where they help.
> 2. Write `todo.md` as a checklist of implementation steps, ordered so each step leaves the app in a runnable state.
> 3. Pause and show me both files before you proceed.
>
> After I approve, implement step-by-step. Update `todo.md` by checking off each item as you finish it. If you discover a planning gap mid-implementation, edit `architecture.md` and call out the change.

The visible artifacts (architecture.md, todo.md, ticked checkboxes) are the wow moment — participants watch the agent "organize itself".

### One-time setup before each workshop

Before the workshop API keys for whichever model need to be provided. Keep in mind that rate limits apply, e.g. at most 1M tokens per key on Azure OpenAI service. Hence creating multiple keys might be necessary.

---

## What's actually running

This is a Create React App project. `npm start` runs the dev server on port 3000 (via the `scripts/start.sh` wrapper that prints the URL first). The devcontainer forwards port 3000 publicly so anyone with the codespace URL can view it.

The starter `src/App.js` renders "Everything works!" — visible confirmation of Checkpoint 3 and a neutral starting point so the LLM doesn't anchor on prior code when participants give it a one-line prompt.
