import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { Configuration, OpenAIApi } from "https://esm.sh/openai@3.2.1"

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

    // Initialize OpenAI (Requires OPENAI_API_KEY environment variable set in Supabase)
    const configuration = new Configuration({ apiKey: Deno.env.get('OPENAI_API_KEY') })
    const openai = new OpenAIApi(configuration)

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

    const response = await openai.createChatCompletion({
      model: 'gpt-4o-mini', // or 'gpt-3.5-turbo' based on cost/performance
      messages: [{ role: 'system', content: prompt }],
      temperature: 0.1,
    })

    const raw_response = response.data.choices[0].message?.content || ''
    
    // Attempt to extract the JSON payload if it is wrapped in markdown
    let jsonString = raw_response;
    if (jsonString.includes('```json')) {
      jsonString = jsonString.split('```json')[1].split('```')[0].trim();
    } else if (jsonString.includes('```')) {
      jsonString = jsonString.split('```')[1].split('```')[0].trim();
    }

    try {
      const parsedOutput = JSON.parse(jsonString);
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
