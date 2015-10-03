# Using Reputation Systems to Create Shared Function-critical Datastructures in Open Networks

Search engines, spam filtration, and p2p protocols - all need to rate the value of information.
Search engines need it to provide good results; spam filtration needs it to exclude noise; and p2p networks need it for security and efficiency.

What is "value?"
I'll use two dimensions:
 - Quality (how useful the information is). The more permissive participation is, the greater the need for quality-ranking. Term-frequency search alone fails for the Web, because the Web doesn't prefilter for quality.
 - Trust (how safe the information is to use). The more function-critical the information is, the greater the need for trust-ranking. If a DHT's host-lookup [can be manipulated to flood an unsuspecting computer (a DDoS)](https://engineering.purdue.edu/~isl/comnet-ddos.pdf) then the DHT is unsound.

**Trust- and quality-ranking are a key feature of open networks with shared data-structures.**
Open networks maximise potential value, because they let agents contribute and extract data independently.
But, this means the nodes must also filter and moderate independently.
Without a means to do so, the network will be overwhelmed, and won't provide any value at all.

Email is an open network: anybody can create a server and account.
And, the inbox a shared structure: users share append-rights over each others' inboxes.
But, without proper spam-filtering, email is nearly useless.
Filtering must be both effective (very little spam) and accurate (*very* few false positives) or email loses its utility.

Two approaches to trust & quality are: Policy-based, and Reputation-based.
From [A survey of trust in computer science and the Semantic Web](http://www.inf.ufsc.br/~gauthier/EGC6006/material/Aula%206/A%20survey%20of%20trust%20in%20computer%20science%20and%20the%20Semantic%20Web.pdf):

> *Policy-based trust*. Using policies to establish trust, focused on managing and exchanging credentials and enforcing access policies. Work in policy-based trust generally assumes that trust is established simply by obtaining a sufficient amount of credentials pertaining to a specific party, and applying the policies to grant that party certain access rights. The recursive problem of trusting the credentials is frequently solved by using a trusted third party to serve as an authority for issuing and verifying credentials.

Policies are manually managed and/or pushed off to 3rd-party authorities, as in the case of DNS registrars and TLS  authorities.
Centralized authorities do not remove the need to rate information; instead they give that task to the authority, and in the process they remove agency from the user.
Centralized authorities are also single points of failure.

Policies are easier to implement, but scale poorly for p2p systems.
CAs for example could never scale to provide credentials for every Web user.

What's the other option?

> *Reputation-based trust.* Using reputation to establish trust, where past interactions or performance for an entity are combined to assess its future behavior. Research in reputation-based trust uses the history of an entity’s actions/behavior to compute trust, and may use referral-based trust (information from others) in the absence of (or in addition to) first-hand knowledge. In the latter case, work is being done to compute trust over social networks (a graph where vertices are people and edges denote a social relationship between people), or across paths of trust (where two parties may not have direct trust information about each other, and must rely on a third party). Recommendations are trust decisions made by other users, and combining these decisions to synthesize a new one, often personalized, is another commonly addressed problem.

Reputation systems are used in search engines, spam filtering (email, forums), and markets (ebay, uber).
They are automated, or they distribute the task of ranking across all agents, and so they tend to scale much better than policies do.
But, they must be designed carefully in order to produce good results.
Bad assumptions or a lack of actionable information can make reputation systems unusable or attackable.

In SSB, we have decided [never to adopt centralized authorities in the protocol](https://github.com/ssbc/docs/blob/master/articles/design-challenge-avoid-centralization-and-singletons.md).
This decision was motivated by
 1. distrust in the quality of global authorities (they are [SPoFs](https://en.wikipedia.org/wiki/Single_point_of_failure))
 2. desire to maximize autonomy of individual users
 3. general curiosity

This constraint pushes us to find novel solutions for shared datastructures.
Though we can use policies, they must be defined by the users; there should not be authorities hardcoded into the software.
In order to avoid manual policy-management, we'll need to employ reputation systems to automate the network's operation.

Can we balance policy and reputation systems to create open & shared datastructures, which scale better and give users more agency?
As an intuitive example, what's to stop us from replacing DNS with a search engine?
This article compiles research and observations, so that we can begin to explore this idea.

---

SSB is a trust network.
(A trust network is just a social network that publishes trust relationships.)
It currently handles only two relationships: 
 - is `a` following `b`? If so, `a` downloads messages by `b`.
 - is `a` blocking `b`? If so, `a` doesnt want `b` to receive messages by `a`.

Let's define "shared datastructures" as *structures which are populated by other agents, and then used in automated decisions by the software.*
Under that definition, there are presently 5 shared datastructures in SSB.
None of them employ trust- or quality-ranking in a sophisticated way, yet.
 - Following. Following uses a transitive "expansion" of the graph: if you follow `b`, you also download everybody that `b` follows. This is called friend-of-a-friend downloading.
 - Blocking. In replication, SSB uses published "blocking" relationships to decide whether to transfer a feed's messages.
 - Petnames. (Not yet in core.) Petnames can be self-assigned, or assigned to others. The policy for using the petnames is very restrictive:
   - The petname must be self-assigned by a followed user, or
   - The petname must be assigned by the local user.
 - Pub announcements. Pub address announcements are shared and used freely.
 - Blob downloads. Blobs linked by followed users are automatically downloaded.

In all but blocking, I believe the policies are overly restrictive (petnames), overly optimistic (pub announcements), or both (following, blob downloads).
There are also other shared data structures we can adopt.
Using reputation in combination with policy, we can potentially improve on:
 - user petnames (who is @bob?)
 - pub announcements (should I sync with this address?)
 - optimistic downloading decisions (should I download this feed or blob without asking the user?)
 - wanted-blob lookup results (which peers will give me blob X?)
 - blob metadata (what's this blob's name, filetype, description, etc?)
 - software safety ratings (is this package safe to run?)
 - search-result recommendations (how should search results be ordered?)
 - filtering and moderation (should this post be hidden?)
 - product and service ratings (is Dans Diner any good?)
 - wiki/knowledge-base assertions (is "the sky is blue" true?)

An ideal system will maximize value while minimizing user effort and bad results.
The quality of shared datastructures becomes very important when

 - You expand the knowledgebase to include strangers. This is a necessary step to improving the quality of results, since it increases the knowledge you can access, but it also forces you to answer more difficult questions, as you have to rate the value of strangers' inputs. 
 - You want to make stronger assumptions about value. For instance, suppose you wanted a `whois` command that gave an immediate single result for a search. `whois bob` -> a single pubkey. This is the quality we expect out of DNS, and it seems conceivable we could get the same from a well-constructed policy+reputation network.
 - You want automated processes to expend resources. Downloading feeds and blobs requires bandwidth and diskspace, but it can improve the user's dataset. Can optimistic following and downloading be automated, in a more sophisticated way than FoaF?

---

PageRank is still one of the top search algorithms in use, so it's important to understand where it fits in the current landscape of research.

[Propagation Models for Trust and Distrust in Social Networks](http://www2.informatik.uni-freiburg.de/~cziegler/papers/ISF-05-CR.pdf) does a good job explaining PageRank's qualities, in section 2.
From there, and from other papers:

 - PageRank is a probabilistic analysis, of a random surfer clicking links through the Web. The common alternative is path-analysis, which is the sort of thing that PGP does in its WoT.
  - [Trust Management for the Semantic Web](https://homes.cs.washington.edu/~pedrod/papers/iswc03.pdf) and [The EigenTrust Algorithm for Reputation Management in P2P Networks](http://ilpubs.stanford.edu:8090/562/1/2002-56.pdf) are two good papers on probabilistic analysis. Both of these try to generalize PageRank. Eigentrust is cited a lot by other papers.
  - [Propagation Models for Trust and Distrust in Social Networks](http://www2.informatik.uni-freiburg.de/~cziegler/papers/ISF-05-CR.pdf) is a good resource for path-analysis, as it explains Advogadro and a novel algorithm called Appleseed.
 - PageRank operates with global information, and seeks to be objective (everyone's opinion) instead of subjective (google's opinion). Google crawls the Web to get global knowledge of the graph. That's not something you'd try to do in a p2p system; instead, you try to apply subjective analysis. However, since an SSB node's dataset is prefiltered (by following) into a  "local neighborhood," then you may be able to apply global-knowledge algorithms like PageRank and get interesting results.
 - PageRank infers that links are recommendations from one page to another. That's usually a correct assumption, but not always. Semantic Web research tries to use richer signals (explicit recommendations of pages, ratings of trust between agents, ratings of belief in facts, etc) and then construct better analysis. 
 - PageRank relies on weblinks being transitive recommendations. The algorithm does *not* apply for recommendations that aren't transitive. Agent trust signals are not always transitive, and distrust signals are *never* transitive.
 - Because PageRank creates global ratings for pages, it's actually estimating the global *reputation* of a page. Reputation is different from trust, because trust is subjective (from a particular node's perspective).
 - Many algorithms, including Eigentrust and Advogato, rely on a seed set of trusted peers. The seed-set makes it possible to detect malicious rings that work together to elevate their rating. The original PageRank paper doesn't have any such seed-set, but in practice I imagine Google has an equivalent.

---

The data model is a very central to the reputation system.
There is no consensus on which model is best; they vary by application and intent.

[The EigenTrust Algorithm for Reputation Management in P2P Networks](http://ilpubs.stanford.edu:8090/562/1/2002-56.pdf) applies probabilistic analysis on a dataset of rated transactions.
After every file-download, users publish whether the downloaded file was as-advertised.
The ratings are accumulated and normalized to quantify the trustworthiness of peers.
The authors assume that trusted peers are likely to make good trust decisions as well, and so they use the trust-values transitively to fill holes in the dataset.
At a glance, [the XRep algorithm](http://eris.prakinf.tu-ilmenau.de/res/papers/security/damiani02reputationbased.pdf) seems to work in roughly the same way.

Eigentrust is not a social system; it's a p2p mesh of file-hosts, which abstracts the hosts away from the user's awareness.
Their data model, therefore, doesn't use direct trust-ratings between agents, whereas SSB can.
In contrast, [the TrustMail algorithm](https://www.cs.umd.edu/~golbeck/pubs/Golbeck,%20Hendler%20-%202004%20-%20Accuracy%20of%20Metrics%20for%20Inferring%20Trust%20and%20Reputation.pdf) sets ratings directly on agents.

[Trust Management for the Semantic Web](https://homes.cs.washington.edu/~pedrod/papers/iswc03.pdf) splits the model into "belief ratings for statements" and "trust ratings for agents"

> [We] propose a solution to the problem of establishing the degree of belief in a statement that is explicitly asserted by one or more sources on the Semantic Web. ... Our basic model is that a user’s belief in a statement should be a function of her trust in the sources providing it.

They offer both path-algebra and probabilistic interpretations for the graph, and a number of options for the formulas.

[Modeling and Evaluating Trust Network Inference](http://ebiquity.umbc.edu/_file_directory_/papers/93.pdf) describes an even more sophisticated model.
First, they isolate trust into domains, following the intuition that an agent may be an expert in one field, but not in another.
Then, in section 2.4.2, they define 2 categories of trust, and subdivide them into 5 types.
The categories are *referral trust* ("reflects an agent’s estimation about the quality of the other agents’ knowledge") and *associative trust* ("reflects the similarity between two agents").
The subdivisions are as follows:
 - Domain Expert Trust (DET) is referral trust that evaluates the quality of an agent’s domain knowledge. Intuitively, DET is not transitive, but DET may imply RET (see next item) on the same domain.
 - Recommendation Expert Trust (RET) is referral trust that evaluates an agent’s trust knowledge. In real world, the domain used in RET is often much wider than DET, e.g. CNN is a domain expert only in news area, while Google.com is a recommendation expert in almost any area. Moreover, RET in transitive according to its definition, so it can be used to propagate both DET and RET.
 - Similar belief trust (SBT) is an associative trust that evaluates the similarity of two agents’ domain knowledge. Intuitively, SBT clusters information providers, and it can be used to propagate DET.
 - Similar trusting trust (STT) is an associative trust that evaluates the similarity of two agents’ trust knowledge. Intuitively, STT clusters trustors (agents who maintain trust knowledge), and it can be used to propagate both DET and RET. Computing STT needs trust knowledge from only two agents.
 - Similar cited trust (SCT) is an associative trust that evaluates the similarity of how two agents are trusted.  Intuitively, STT clusters trustees (agents who are trusted) by their reputation, and it can be used to propagate both DET and RET. Reliable SCT requires trust knowledge from a large population of agents.

This is not the first group to separate DET and RET.
The [Hilltop](https://en.wikipedia.org/wiki/Hilltop_algorithm) and [HITS](https://en.wikipedia.org/wiki/HITS_algorithm) algorithms make that distinction as well.

The values used to rate agents or data varies between the algorithms.
Roughly, they tend to be trinary (trusted/distrusted/no-opinion) or real (0..1, or 0..10, etc).
I've found nothing definitive about which is best.

When choosing the model, we should remember that reputation systems exist to rank information in the absense of local input.
If the user were able to rate all inputs a-priori, a policy system would suffice.
Since the user can not, a reputation system merges the inputs of many users to fill holes in the data structure.

---

A few notes on how computation occurs.
In addition to the path-algebra vs probabilistic analysis, there's a split among the papers between making distributed vs centralized/localized computations.

Distributed computation uses realtime queries to peers for trust information.
Centralized/localized computation aggregates information at a node, and then computes across that aggregated information.

Both Google and SSB qualify as centralized/localized.
The difference is that Google tries to obtain global knowledge of the network, via crawling, while SSB obtains a localized neighborhood of the network.

We may, in the future, choose to supplement SSB's localized computation with distributed protocols, but I don't see a pressing need to do so.

---

If we want to entrust function-critical decisions to shared data, we need to be robust to malicious behaviors.
The [Appleseed Paper](http://www2.informatik.uni-freiburg.de/~cziegler/papers/ISF-05-CR.pdf) provides useful analysis of this:

> The “bottleneck property” [is] common feature of attack-resistant trust metrics. Informally, this property states that the “trust quantity accorded to an edge `s → t` is not significantly affected by changes to the successors of t.”

Put another way, the bottleneck property holds if a voting ring is not able to elevate its reputation the network by recommending each other.
This property requires subjectivity: trust must flow outward from a seed set.
Fortunately, SSB is subjective by nature.

The other concern we must address is compromise-risk: we should minimize the danger of a trusted node acting maliciously.
Two techniques for handling this:
 - Always distribute authority. A security-critical change should be backed by multiple trusted agents.
 - Watch for anomolous events and alert the user. If a kind of change is rare, confirm it before accepting it.

---

It may be possible to generalize a universal system for ranking the trust and quality of data in SSB.
If so, then a single "ranking" application would be able to publish and review data structures.
However, I'm unsure that's possible.
In the near-term, I suggest we study applications and data-structures separately, and watch for unifying principles.

There are a few applications which I think we should focus our attention on, because they'll yield the most insight, and value, to the network.
 - An intelligent crawler which expands on FoaF following. This application would start with the user's explicit follows, and then analyze the network to find feeds, messages, and blobs that are worth downloading. This might be viewed as attempting to automate virality. The algorithm will need to balance its options against available disk space.
 - A search engine for messages, feeds, and blobs. This is a very broad application, and so may be hard to address early, but it will have a lot of relevance, insight, and value for the network. It also makes a strong companion to the intelligent crawler, as it lets you discover what the crawler has fetched for you. And, the queries may act as inputs to the crawler, since queries signal your interests.
 - A whois (petnames) application. Petnames are core to the system, and are a bit more narrowly-defined, so they may be easier to approach early on. Lessons in whois could apply in tougher applications.
 - A wiki/knowledgebase. A very broad application, but also not very function-critical, and so a little easier to write.