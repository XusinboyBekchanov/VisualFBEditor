deepseek-chat
deepseek-reasoner
deepseek-reasoner
{split}
api.deepseek.com
api.deepseek.com
{split}
chat/completions
chat/completions
{split}
443
80
443
{split}
1
{split}
true
{split}


{split}
Content-Type: application/json; charset=utf-8
Authorization: Bearer {apikey}

{split}
{
  "model": "{model name}",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
{assistant}    {"role": "user", "content": "{content}!"}
  ],
  "stream": {stream}
}

{split}
       {"role":"user","content":"{content}"},
       {"role":"assistant","content":"{assistant}"},

{split}
{"index":0,"delta":{"content":"{}{"index":0,"delta":{"content":"{}"content":"
","reasoning_content":null}{}"},"logprobs":null,"finish_reason":null}{}","reasoning_content":"
{}
{split}
{"content":null,"reasoning_content":"{}","reasoning_content":"
"},"logprobs":null,"finish_reason"{}"},"logprobs":null
{}