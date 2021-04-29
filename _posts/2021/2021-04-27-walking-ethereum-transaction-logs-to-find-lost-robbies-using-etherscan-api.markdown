---
layout: post
title: Walking Ethereum Transaction Logs to Find Lost Robbies w/Etherscan API   
date: 2021-04-27
tags: [ethereum, etherscan, crypto, robbies]
redirect_from: "/2021/04/27/walking-etherium-transaction-logs-to-find-lost-robbies-using-etherscan-api.html"
comments: true
---
On July 17, 2018, I [spoke](https://www.youtube.com/watch?v=KT-gPtK5uHY&t=4h13m20s) at the Christies first ever annual Tech Summit entitled "Exploring Blockchain", in London. I even got a freebie NFT!

During the event [SuperRare](http://superrare.io/) partnered with [Jason Bailey](https://www.artnome.com/about-artnome) and enlisted [Robbie Barrat](https://robbiebarrat.github.io/), the first artist to ever tokenize on SuperRare. Robbie created "AI Generated Nude Portrait #7" for the event, which he intended as 300 separate frames of a single artwork. Each of the 300 frames was tokenized separately and added to redeemable ETH gift cards with directions for how to claim the 1/1 token. 

A small handful of these original NFTs are known to still exist. We'll call them "Robbies". On April 5th, 2021, [frame 269](https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-269-459) sold for 125ETH ($265K). 

If you enjoyed the forensics in [Rare “Lost Robbie” AI Nude NFTs Worth Millions Surface](https://digitalartcollector.com/rare-lost-robbie-ai-nude-nfts-worth-millions-surface/), or if you just want to know how SuperRare or other marketplaces display token history, this post is for you. We'll walk the Ethereum blockchain transaction logs to find all the Robbies using [etherscan-api](https://www.npmjs.com/package/etherscan-api) ([Etherscan API](https://etherscan.io/apis)). 

Please do note that I am no expert, and that I would greatly appreciate suggestions and fixes to my approach and [the code](https://github.com/dblock/lost-robbies).

An freebie OBJKT NFT was also minted, inspired by this project. Available at [hicetnunc.xyz/objkt/53103](https://www.hicetnunc.xyz/objkt/53103).

### Getting Started

First, get an `ETHERSCAN_API_KEY` from [Etherscan](https://etherscan.io/myapikey) and save it to a file called `.env`. We'll use [dotenv](https://www.npmjs.com/package/dotenv) to automatically load it, and initialize `EtherscanApi` with this key.

{% highlight typescript %}
import * as dotenv from 'dotenv';
import * as EtherscanApi from 'etherscan-api';

var api = null;

async function init() {
  dotenv.config();
  var etherscanApiKey = process.env.ETHERSCAN_API_KEY;
  if (! etherscanApiKey) { throw new Error('Missing ETHERSCAN_API_KEY') }
  api = EtherscanApi.init(etherscanApiKey);
}
  
async function main() {
  try {
    await init();
    // do something useful here
  } catch(error) {
    console.log(error)
  }
}

main();
{% endhighlight %}

The rest of the code goes somewhere into that _do something useful here_ part above.

### Who is Robbie?

Robbie Barrat, or [@videodrome](https://superrare.co/videodrome) is [0x860c4604fe1125ea43f81e613e7afb2aa49546aa](https://etherscan.io/address/0x860c4604fe1125ea43f81e613e7afb2aa49546aa). I found that address by following transaction links on SuperRare.

{% highlight typescript %}
var balance = (await api.account.balance('0x860c4604fe1125ea43f81e613e7afb2aa49546aa')).result;
console.log("Robbie has " + (balance / 1000000000000000000).toFixed(2).toString() + " ETH");
{% endhighlight %}

This says Robbie has earned 118.66 ETH (~$317K) from sales so far. Not bad.

### SuperRare Contract

Ethereum transactions execute methods that are written in a _contract_, which is basically a bunch of code that implements a set of known methods (an interface, e.g. [ERC721](https://github.com/ethereum/eips/issues/721)). As all code, method have inputs and outputs. The SuperRare contract is [0x41a322b28d0ff354040e2cbc676f0320d8c8850d](https://etherscan.io/address/0x41a322b28d0ff354040e2cbc676f0320d8c8850d), also found by examining a transaction linked from SuperRare.

Contracts are expressed in JSON, include method names, inputs, outputs, and other metadata. Contracts, along with all inputs and outputs on Ethereum, are encoded in binary format, using an application binary interface (ABI). We can fetch the contract with `contract.getabi`.

{% highlight typescript %}
var abi = await api.contract.getabi('0x41a322b28d0ff354040e2cbc676f0320d8c8850d');
var json = JSON.parse(abi.result);
{% endhighlight %}

The ABI also gives you the ability to create an instance of a [ethereum-input-data-decoder](https://www.npmjs.com/package/ethereum-input-data-decoder) to decode data in transactions that had been executed under this contract with `new InputDataDecoder(json)`.

### Transactions and Logs

Ethereum transactions are a series of method calls. Each transaction has an address, input arguments and output results. Each method call inside a transaction receives input, or _topics_, that can be _indexed_. A successful method call creates a log entry. Etherscan lets you query logs that belong to a certain contract using indexed topics.

For example, you can query logs for all method calls for the SuperRare contract.

{% highlight typescript %}
var logs = await api.log.getLogs('0x41a322b28d0ff354040e2cbc676f0320d8c8850d');
logs.result // first page of a lot of logs
{% endhighlight %}

### Dude, where's my NFT?

So, what's the address of my NFT? Well, there isn't one.

The SuperRare contract _mints_ a new NFT as a side effect of a call to the `addNewToken` method. The `addNewToken` call increments `totalSupply()` of tokens to obtain a new token ID. By convention, this looks like a transfer from address `0x00` to the caller using the `Transfer` method.

Take a look at [the first Nude Portrait #7 token creation transaction](https://etherscan.io/tx/0x397cf219aadb0e25afc7fcbb35f36ebccd8611375b5c7ad888e4cbacced2d7ea). The transaction address was `0x397cf219aadb0e25afc7fcbb35f36ebccd8611375b5c7ad888e4cbacced2d7ea`. It called the `addNewToken` method with an `_uri` of `https://ipfs.pixura.io/ipfs/QmWkvzP1FZBrwBXjj3vD258RQm9MtV25G69zcqzYmc1cGd`, which contains the JSON of frame #1.

{% highlight json %}
{
    name: "AI Generated Nude Portrait #7 Frame #1",
    description: "Artwork generated by a GAN trained on thousands of nude portrait oil paintings.",
    yearCreated: "2018",
    createdBy: "Robbie Barrat",
    tags: [
        ""Nude Portrait",
        "AI",
        "Painting",
        "Portrait",
        "Generative",
        "GAN",
        "Machine Learning",
        "Artificial Intelligence",
        "Nude",
        "Abstract"",
        ""image.jpg""
    ],
    image: "https://ipfs.pixura.io/ipfs/QmaFkStftgA9rW9NyKUFyCKhAvKkENtD1CUfCkzEAWghyr"
}
{% endhighlight %}

The output of this transaction was a `_tokenId` of `191`. Navigating to [superrare.co/artwork/191](https://superrare.co/artwork/191) will incidentally show you the first frame from "Nude Portrait #7".

### Finding Create Transactions

As I described above, creating a token means calling `Transfer` from address `0x00`. The `tokenId` argument, however, is not indexed, so I could not find how to get the transaction that created, for example, token number 191. However, I figured out how to find all the transactions that generated the 300 tokens by specifying the source address of `0x00`.

{% highlight typescript %}
api.log.getLogs(
  '0x41a322b28d0ff354040e2cbc676f0320d8c8850d', // contract address
  '5977236', // fromBlock, from https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-1-191
  '5977931', // toBlock, from https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-300-490
  null,
  null,
  '0x0000000000000000000000000000000000000000000000000000000000000000' // from at creation
);
{% endhighlight %}

### Examining a Transaction

Now that we have a collection of 300 logs, we can, for each `log`, get the corresponding transactions, decode input data, identify the method called, etc. 

{% highlight typescript %}
var tx = (await api.proxy.eth_getTransactionByHash(log.transactionHash)).result;

// _uri: https://ipfs.pixura.io/ipfs/QmWkvzP1FZBrwBXjj3vD258RQm9MtV25G69zcqzYmc1cGd
const decodedInputData = inputDataDecoder.decodeData(tx.input); 

// addNewToken
const method = decodedInputData.method; 
{% endhighlight %}

### First Transfers

After creation, the tokens were transferred from @videodrome's address into newly created wallets. Those transfers are indexed by the sender's address. Again, because the `tokenId` is not indexed in these transactions, I couldn't figure out how to query all transfer logs for a single token, but we can get the entire set.

{% highlight typescript %}
api.log.getLogs(
  '0x41a322b28d0ff354040e2cbc676f0320d8c8850d', // contract address
  '5977931', // fromBlock, from https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-1-191
  '5979502', // toBlock, from https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-300-490
  null,
  null,
  '0x000000000000000000000000860c4604fe1125ea43f81e613e7afb2aa49546aa' // videodrome's address
);
{% endhighlight %}

### Sales and Bids

Reading the contract shows that `bid`, `acceptBid` and `buy` event logs are indexed by `tokenId` as the 3rd topic. 

{% highlight typescript %}
// e.g. '0x0000000000000000000000000000000000000000000000000000000000000126'
var topic = '0x' + tokenId.toString(16).padStart(64, '0');

api.log.getLogs(
  '0x41a322b28d0ff354040e2cbc676f0320d8c8850d',
  null, // fromBlock
  null, // toBlock
  null, // topic0
  null, // topic0_1_opr
  null, // topic1
  null, // topic1_2_opr
  null, // topic2
  null, // topic2_3_opr
  topic, // topic3, tokenId
  null
);
{% endhighlight %}

Similarly, `setSalePrice` is indexed by `tokenId` as the 1st topic.

{% highlight typescript %}
api.log.getLogs(
  '0x41a322b28d0ff354040e2cbc676f0320d8c8850d',
  null, // fromBlock
  null, // toBlock
  null, // topic0
  null, // topic0_1_opr
  topic // topic1
);
{% endhighlight %}

Decoding inputs in these logs tells us, for example, the amount for the sale price set (`parseInt(log.topics[2], 16)`) or the transaction timestamp (`moment.unix(parseInt(log.timeStamp, 16))`).

### Putting It All Together

The complete code to this blog post is [here](https://github.com/dblock/lost-robbies). It fetches and stores the initial create transactions, subsequent transfer transactions, then all the sales transactions. 

Run `npm run update` to fetch any new data updates, cached locally, and `npm run sales` to show the most recent sales.

{% highlight bash %}
frame 13 sold for 100.888 ETH on Sat Apr 10 2021 00:40:21 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-13-203
frame 24 sold for 0.100 ETH on Fri Jul 20 2018 10:32:22 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-24-214
frame 44 was listed for sale for 350.000 ETH on Sun Apr 25 2021 16:42:41 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-44-234
  sold for 110.000 ETH on Mon Apr 19 2021 14:17:32 GMT-0400
frame 45 sold for 100.888 ETH on Fri Apr 09 2021 15:38:00 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-45-235
frame 53 was listed for sale for 2500.000 ETH on Wed Mar 24 2021 21:44:31 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-53-243
frame 65 was listed for sale for 545.000 ETH on Sun Apr 04 2021 22:14:41 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-65-255
  sold for 47.000 ETH on Sun Apr 04 2021 08:32:42 GMT-0400
frame 78 was listed for sale for 222.000 ETH on Fri Apr 23 2021 17:37:51 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-78-268
frame 92 was listed for sale for 122.000 ETH on Mon Apr 26 2021 16:58:29 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-92-282
  sold for 50.000 ETH on Mon Apr 05 2021 13:50:40 GMT-0400
frame 101 was listed for sale for 5555.000 ETH on Fri Mar 12 2021 07:11:07 GMT-0500 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-101-291
  sold for 1.500 ETH on Mon Dec 02 2019 13:46:32 GMT-0500
frame 104 was listed for sale for 1000.000 ETH on Mon Mar 15 2021 16:12:56 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-104-294
  sold for 19.000 ETH on Thu Jun 11 2020 16:28:09 GMT-0400
frame 149 was listed for sale for 888.000 ETH on Wed Mar 24 2021 08:29:05 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-149-339
  sold for 35.000 ETH on Tue Aug 04 2020 02:06:33 GMT-0400
frame 153 sold for 16.500 ETH on Wed Jan 01 2020 15:37:56 GMT-0500 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-153-343
frame 165 was listed for sale for 2000.000 ETH on Mon Apr 05 2021 15:52:17 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-165-355
frame 166 was listed for sale for 2200.000 ETH on Mon Apr 19 2021 22:24:50 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-166-356
  sold for 80.000 ETH on Sat Apr 03 2021 03:56:19 GMT-0400
frame 175 sold for 0.001 ETH on Sat Jul 11 2020 23:54:29 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-175-365
  sold for 0.001 ETH on Sat Jul 11 2020 23:37:43 GMT-0400
  sold for 0.001 ETH on Sat Jul 11 2020 23:30:37 GMT-0400
  sold for 0.001 ETH on Sat Jul 11 2020 23:14:22 GMT-0400
  sold for 21.000 ETH on Mon Jun 29 2020 22:48:05 GMT-0400
  sold for 1.500 ETH on Sat Dec 21 2019 00:09:56 GMT-0500
frame 179 was listed for sale for 299.000 ETH on Mon Apr 12 2021 21:17:18 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-179-369
frame 206 sold for 60.000 ETH on Wed Apr 07 2021 15:40:30 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-206-396
frame 269 sold for 125.000 ETH on Mon Apr 05 2021 16:36:12 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-269-459
frame 275 was listed for sale for 885.000 ETH on Mon Apr 19 2021 22:25:38 GMT-0400 | https://superrare.co/artwork/ai-generated-nude-portrait-7-frame-275-465
  sold for 50.000 ETH on Wed Apr 07 2021 19:29:54 GMT-0400
{% endhighlight %}

