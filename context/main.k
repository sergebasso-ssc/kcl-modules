import crypto
import ...utils

schema Context:
    """Generate consistent, reusable, and compliant resource names and labels.
    This is inspired by the Cloud Posse terraform-null-label module.

    References
    ----------
    https://registry.terraform.io/modules/cloudposse/label/null/latest
    https://github.com/cloudposse/terraform-null-label/blob/main/main.tf

    """

    _defaults: {str: any} = {
        delimiter = "-"
        idHashLength = 8
        idLengthLimit = 0
        labelOrder = ["namespace", "environment", "stage", "name", "attributes", "tenant"]
    }

    context?: Context
    namespace?: str
    environment?: str
    stage?: str
    name?: str
    attributes: [str] = []
    tenant?: str
    delimiter?: str
    idHashLength?: int
    idLengthLimit?: int
    labelOrder?: [str]
    prefix?: str

    # Create the effective context from input context, overrides, and defaults.
    # This can be passed to other labels as context.
    effectiveContext: {str: any} = {
        "namespace" = context?.namespace or namespace
        "environment" = context?.environment or environment
        "stage" = context?.stage or stage
        "name" = context?.name or name
        "attributes" = utils.distinct((context?.attributes or []) + (attributes or []))
        "tenant" = context?.tenant or tenant
        "delimiter" = context?.delimiter or delimiter or _defaults.delimiter
        "idHashLength" = context?.idHashLength or idHashLength or _defaults.idHashLength
        "idLengthLimit" = context?.idLengthLimit or idLengthLimit or _defaults.idLengthLimit
        "labelOrder" = context?.labelOrder or labelOrder or _defaults.labelOrder
    }

    passContext: {str: any} = {
        namespace = effectiveContext.namespace
        environment = effectiveContext.environment
        stage = effectiveContext.stage
        name = effectiveContext.name
        attributes = effectiveContext.attributes
        tenant = effectiveContext.tenant
    }

    # Build the full ID and compute its hash
    _idContext = {
        "namespace" = effectiveContext.namespace
        "environment" = effectiveContext.environment
        "stage" = effectiveContext.stage
        "name" = effectiveContext.name
        "attributes" = effectiveContext.delimiter.join(effectiveContext.attributes)
        "tenant" = effectiveContext.tenant
    }
    idFull: str = effectiveContext.delimiter.join([
        _idContext[x] for x in  effectiveContext.labelOrder if _idContext[x]
    ])
    idHash: str = crypto.sha256(idFull)[:effectiveContext.idHashLength]

    # Generate the ID
    id: str = (lambda -> str {
        """Generate the ID based on the full ID and hash, respecting length
        limits. If the full ID does not exceed the length limit, it is returned
        as-is, otherwise the full ID will be truncated and the hash appended.
        If included, the hash will never be truncated.
        """
        idTruncatedLengthLimit = effectiveContext.idLengthLimit - (len(idHash) + len(effectiveContext.delimiter))
        idTruncated = "" if idTruncatedLengthLimit <= 0 else "${utils.trimSuffix(idFull[:idTruncatedLengthLimit], effectiveContext.delimiter)}${effectiveContext.delimiter}"
        idShort = "${idTruncated}${idHash}"[:effectiveContext.idLengthLimit]
        id = idShort if effectiveContext.idLengthLimit != 0 and len(idFull) > effectiveContext.idLengthLimit else idFull
        id
    })()

    # Generate the prefixed ID
    prefixedId: str = (lambda -> str {
        """Generate the prefixed ID based on the prefix and hash, respecting
        length limits. If the prefix and hash do not exceed the length limit, it
        is returned as-is, otherwise the prefix will be truncated and the hash
        appended. If included, the hash will never be truncated.
        """
        prefixedIdTruncatedLengthLimit = effectiveContext.idLengthLimit - (len(idHash) + len(effectiveContext.delimiter))
        prefixTruncated = "" if prefixedIdTruncatedLengthLimit <= 0 else "${utils.trimSuffix(prefix[:prefixedIdTruncatedLengthLimit], effectiveContext.delimiter)}${effectiveContext.delimiter}"
        prefixedIdShort = "${prefixTruncated}${idHash}"[:effectiveContext.idLengthLimit]
        prefixedId = prefixedIdShort if effectiveContext.idLengthLimit != 0 and len("${prefix}${effectiveContext.delimiter}${idHash}") > effectiveContext.idLengthLimit else "${prefix}${effectiveContext.delimiter}${idHash}"
        prefixedId
    })() if prefix else ""

    check:
        not idLengthLimit or idLengthLimit == 0 or idLengthLimit >= 8, "idLengthLimit must be >= 8 if supplied, or 0 for unlimited length."
        not idHashLength or idHashLength == 0 or idHashLength >= 8, "idHashLength must be >= 8 if supplied, or 0 for unlimited length."
        not idHashLength or idHashLength == 0 or not idLengthLimit or idLengthLimit == 0 or idHashLength <= idLengthLimit, "idHashLength must be <= idLengthLimit if both are supplied and non-zero."
