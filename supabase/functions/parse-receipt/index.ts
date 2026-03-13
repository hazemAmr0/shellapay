import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { raw_text } = await req.json()

    if (!raw_text) {
      return new Response(JSON.stringify({ error: 'raw_text is required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // Google Gemini API Key (Set this in Supabase env variables as GEMINI_API_KEY)
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      return new Response(JSON.stringify({ error: 'GEMINI_API_KEY is not set' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    const prompt = `
Extract the individual line items and their prices from the following raw OCR text of a receipt.
Output MUST be valid JSON with this exact structure:
{
  "items": [
    { "item": "string - precise name of the item", "price": 0.00 }
  ]
}
Ignore subtotals, tax, date, merchant, or totals. Include only purchased items.
Use Arabic if the text is in Arabic, or English if it's in English. 

Raw OCR Text:
"""
${raw_text}
"""
`

    const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`

    const response = await fetch(geminiEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: prompt }]
        }],
        generationConfig: {
            temperature: 0.1,
            responseMimeType: "application/json",
        }
      })
    })

    const responseData = await response.json()
    
    // Extract the raw response text from Gemini
    const raw_response = responseData.candidates?.[0]?.content?.parts?.[0]?.text || ''
    
    try {
      // Gemini 1.5 Flash might already return clean JSON if responseMimeType is set
      const parsedOutput = JSON.parse(raw_response);
      return new Response(JSON.stringify({ items: parsedOutput.items, raw_response }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    } catch (parseError) {
      return new Response(JSON.stringify({ error: 'Failed to parse receipt', raw_response }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 422,
      })
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Internal server error', details: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
