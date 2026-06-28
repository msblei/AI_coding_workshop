# AI Coding Workshop

Welcome! Your workspace is ready and you're already logged in. There are just **two steps**:
Set up Cline, then start building. Raise your hand if you get stuck.

## Your live app

Your app is **already running** and visible at:

### {{APP_URL}}

Open that in a new browser tab and keep it handy. It should say "Everything works!" on there.
As you edit the code, that page updates automatically.

## Step 1: Set up Cline (OpenRouter)

<!-- This section is identical to the Codespaces guide in the repo README.md.
     If you change it here, change it there too. -->

1. Click the **Cline robot icon** in the left sidebar. A panel opens.

   ![Cline icon in the sidebar](resources/cline_icon.png)

2. Choose **"Bring my own API key"**, then set **API Provider** to **OpenRouter**.

   <!-- TODO screenshot: Cline API Provider dropdown set to "OpenRouter" -> resources/cline_openrouter_provider.png -->
   ![Select Bring my own API key](resources/cline_bring_your_own_key.png)   
   ![Select OpenRouter as the provider](resources/cline_openrouter_provider.png)

3. Paste this **OpenRouter API key**:

   ```
   {{OPENROUTER_KEY}}
   ```

4. Set the **Model** to `anthropic/claude-sonnet-4.6`, then save.

   <!-- TODO screenshot: Cline OpenRouter key + model filled in -> resources/cline_openrouter_config.png -->
   ![Paste the key and pick a model](resources/cline_openrouter_provider.png)

5. In the Cline chat box, send any message (e.g. *"Hello! Say hi back so I know you're working."*)
   and wait a few seconds for a reply.

   ![Cline replying to the test message](resources/cline_success.png)

## Step 2: Start building

Cline is ready. Wait for the facilitator's first exercise.

- Toggle **Plan / Act** at the top of the Cline panel — the facilitator will say which to use.
- Your app auto-reloads on every change; just refresh your app tab if it looks stale.
- This guide stays in the project as `README.md` — reopen it from the file explorer anytime.
