// Function Calling機能のテスト用スクリプト
const { OpenAI } = require('openai');

// 現在時刻を取得する関数
const getCurrentTime = () => {
    const now = new Date();
    return {
        current_time: now.toISOString(),
        formatted_time: now.toLocaleString('ja-JP', {
            timeZone: 'Asia/Tokyo',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        }),
        timestamp: now.getTime()
    };
};

// Function Callingのスキーマ
const functionSchemas = [
    {
        type: "function",
        function: {
            name: "get_current_time",
            description: "現在の日時を取得します。ユーザーが時刻や日付を知りたい場合に使用してください。",
            parameters: {
                type: "object",
                properties: {},
                required: []
            }
        }
    }
];

// テスト実行
async function testFunctionCalling() {
    console.log('Function Calling テストを開始します...');
    
    // Azure OpenAI設定（環境変数がない場合はダミーでテスト）
    const endpoint = process.env.AZURE_OPENAI_ENDPOINT || 'dummy';
    const apiKey = process.env.AZURE_OPENAI_API_KEY || 'dummy';
    
    if (endpoint === 'dummy' || apiKey === 'dummy') {
        console.log('Azure OpenAI環境変数が設定されていません。ローカルテストを実行します。');
        
        // ローカルで関数のテスト
        console.log('現在時刻取得関数のテスト:');
        const timeResult = getCurrentTime();
        console.log(JSON.stringify(timeResult, null, 2));
        
        // 関数スキーマの構造テスト
        console.log('Function Schema テスト:');
        console.log(JSON.stringify(functionSchemas, null, 2));
        
        console.log('ローカルテストが完了しました。');
        return;
    }
    
    try {
        const client = new OpenAI({
            apiKey: apiKey,
            baseURL: `${endpoint}/openai/deployments/${process.env.AZURE_OPENAI_DEPLOYMENT_NAME || 'gpt-35-turbo'}`,
            defaultQuery: { 'api-version': '2024-02-15-preview' },
            defaultHeaders: {
                'api-key': apiKey,
            },
        });

        const messages = [
            {
                role: 'system',
                content: '現在の時刻を聞かれたら、get_current_time関数を使用して回答してください。'
            },
            {
                role: 'user',
                content: '今の時刻を教えてください'
            }
        ];

        console.log('Azure OpenAI APIに問い合わせ中...');
        const completion = await client.chat.completions.create({
            model: process.env.AZURE_OPENAI_DEPLOYMENT_NAME || 'gpt-35-turbo',
            messages: messages,
            tools: functionSchemas,
            tool_choice: "auto",
            max_tokens: 500,
            temperature: 0.7
        });

        const choice = completion.choices[0];
        const responseMessage = choice.message;

        console.log('OpenAI レスポンス:');
        console.log(JSON.stringify(responseMessage, null, 2));

        if (responseMessage.tool_calls && responseMessage.tool_calls.length > 0) {
            console.log('Function Calling が検出されました！');
            
            for (const toolCall of responseMessage.tool_calls) {
                console.log(`関数名: ${toolCall.function.name}`);
                
                if (toolCall.function.name === 'get_current_time') {
                    const result = getCurrentTime();
                    console.log('関数実行結果:');
                    console.log(JSON.stringify(result, null, 2));
                }
            }
        } else {
            console.log('Function Calling は使用されませんでした。');
        }

    } catch (error) {
        console.error('テストエラー:', error.message);
    }
}

// テストの実行
if (require.main === module) {
    testFunctionCalling();
}

module.exports = { getCurrentTime, functionSchemas, testFunctionCalling };