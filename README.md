# kvaps's krew-index

[Krew] index repository with my plugins

[Krew]: https://github.com/kubernetes-sigs/krew


##### install repository:

    kubectl krew index add kvaps https://github.com/kvaps/krew-index

##### list available plugins:

    kubectl krew search kvaps

##### install plugins:

    kubectl krew install kvaps/build
    kubectl krew install kvaps/node-shell
    kubectl krew install kvaps/use
