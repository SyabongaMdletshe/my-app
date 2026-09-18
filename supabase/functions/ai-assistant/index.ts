const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY");

const SYSTEM_PROMPT = `
You are Khetha AI, a helpful career guidance assistant for South African learners.
Answer questions about careers, school subjects, qualifications, and study options.
Keep answers short (max 4 sentences), friendly, and use simple English.
`;

Deno.serve(async (req) => {
  const cors = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    if (!GROQ_API_KEY) {
      return new Response(
        JSON.stringify({ reply: "ERROR: GROQ_API_KEY missing." }),
        { headers: { ...cors, "Content-Type": "application/json" } },
      );
    }

    const { message } = await req.json();

    const res = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${GROQ_API_KEY}`,
      },
      body: JSON.stringify({
                      model: "openai/gpt-oss-120b",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: message },
        ],
        temperature: 0.7,
        max_tokens: 300,
      }),
    });

    const data = await res.json();

    if (!res.ok) {
      return new Response(
        JSON.stringify({
          reply: `Groq error ${res.status}: ${
            data?.error?.message ?? JSON.stringify(data)
          }`,
        }),
        { headers: { ...cors, "Content-Type": "application/json" } },
      );
    }

    const reply = data?.choices?.[0]?.message?.content ?? "No reply.";

    return new Response(JSON.stringify({ reply }), {
      headers: { ...cors, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ reply: "Exception: " + String(e) }), {
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }
});