BNO Demo
========

Start the network by running `docker-compose up`.
This will provision a four-node network with two conventional nodes (_Alice_, _Bob_), a business network operator node (_Charly_) and a notary (_Notary_).
All nodes can be accessed via SSH with the user name `user` and password `secret`.
Nodes expose ports to the host system, so a connection can be made like this: `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user@localhost -p 10004`.

Participants
------------

| Identity                                                                                | SSH Port |
|-----------------------------------------------------------------------------------------|----------|
| O=Alice Ltd., L=Shanghai, C=CN                                                          | 10004    |
| O=Bob Ltd., L=Beijing, C=CN                                                             | 20004    |
| O=Notary Organisation, OU=Department of Notarisation, L=London, C=GB                    | 30004    |
| O=Consortium Charly, OU=Consortium Management Department, L=Shenzhen, S=Guangzhou, C=CN | 40004    |

Example Sequence
----------------

| Execute as | Command                                                                                                                                                                      | Expected Result                                                                                                                                                                                                                                                                    |
|------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Alice      | `flow start GetMembersFlow bno: "O=Consortium Charly, OU=Consortium Management Department, L=Shenzhen, S=Guangzhou, C=CN", forceRefresh: false, filterOutNotExisting: false` | Alice is unable to obtain the list of members as she is not a member herself: `Counterparty O=Alice Ltd., L=Shanghai, C=CN is not a member of this business network`                                                                                                               |
| Alice      | `flow start Ping counterparty: "O=Bob Ltd., L=Beijing, C=CN"`                                                                                                                | Alice is unable to transact with Bob as they are not members of the same network: `Counterparty O=Bob Ltd., L=Beijing, C=CN is not a member of this business network`                                                                                                              |
| Alice      | `flow start RequestMembershipFlow bno: "O=Consortium Charly, OU=Consortium Management Department, L=Shenzhen, S=Guangzhou, C=CN", membershipMetadata: {}`                    | Alice can request membership but does not become a member right away. Her request is in pending state: `Flow completed with result: SignedTransaction(id=…)`                                                                                                                       |
| Bob        | `flow start RequestMembershipFlow bno: "O=Consortium Charly, OU=Consortium Management Department, L=Shenzhen, S=Guangzhou, C=CN", membershipMetadata: {}`                    | Bob can request membership but does not become a member right away. His request is in pending state: `Flow completed with result: SignedTransaction(id=…)`                                                                                                                         |
| Charly     | `flow start ActivateMembershipForPartyFlow party: "O=Alice Ltd., L=Shanghai, C=CN"`                                                                                          | Charly, as business network operator, can activate the membership for Alice: `Flow completed with result: SignedTransaction(id=…)`                                                                                                                                                 |
| Charly     | `flow start ActivateMembershipForPartyFlow party: "O=Bob Ltd., L=Beijing, C=CN"`                                                                                             | Charly, as business network operator, can activate the membership for Bob:`Flow completed with result: SignedTransaction(id=…)`                                                                                                                                                    |
| Alice      | `flow start GetMembersFlow bno: "O=Consortium Charly, OU=Consortium Management Department, L=Shenzhen, S=Guangzhou, C=CN", forceRefresh: false, filterOutNotExisting: false` | Now Alice can see the list of members since she is a member herself: `Flow completed with result: [PartyAndMembershipMetadata(party=O=Alice Ltd., L=Shanghai, C=CN, membershipMetadata={}), PartyAndMembershipMetadata(party=O=Bob Ltd., L=Beijing, C=CN, membershipMetadata={})]` |
| Alice      | `flow start Ping counterparty: "O=Bob Ltd., L=Beijing, C=CN"`                                                                                                                | The flow now completes successfully (`Flow completed with result: kotlin.Unit`).                                                                                                                                                                                                   |
