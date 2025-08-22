# Salesforce Connected Apps Security Changes - Questions for CSM & Support

## **Impact Assessment & Timeline**

1. **What is the exact rollout date for our org?** (New vs. existing org timeline)
1. **How can we identify all uninstalled connected apps currently in use in our org?**
1. **Which of our current integrations and tools will be affected by these changes?**
1. **Do we have any OAuth 2.0 Device Flow authentication currently in use beyond Data Loader?**
1. **What happens to existing user sessions and authorizations when the changes take effect?**

## **Data Loader Specific Questions**

1. **What are the alternative authentication methods for Data Loader after September 2, 2025?**
1. **Will there be a new version of Data Loader released to support the changes?**
1. **How do we migrate existing Data Loader configurations and scheduled jobs?**
1. **Will bulk data operations be impacted during the transition period?**
1. **Are there any performance differences between the old and new authentication methods?**

## **Security & Permissions Management**

1. **How do we audit and review all connected apps before the deadline?**
1. **What’s the recommended approach for the new “Approve Uninstalled Connected Apps” permission?**
1. **When should we use “Use Any API Client” vs “Approve Uninstalled Connected Apps” permissions?**
1. **How can we identify if our org has been targeted by social engineering attacks?**
1. **What security monitoring should we implement for connected apps going forward?**

## **Technical Implementation**

1. **How do we properly “install” connected apps that we want to keep using?**
1. **What’s the process for converting uninstalled connected apps to installed ones?**
1. **Will API Access Control settings affect how these changes impact our org?**
1. **Are there any changes to SAML SSO or other authentication flows?**
1. **How do we test the new authentication methods before the cutover date?**

## **Business Continuity & Risk Management**

1. **What’s our recommended testing timeline to ensure no business disruption?**
1. **How do we communicate these changes to end users and developers?**
1. **What’s the rollback plan if we encounter issues after the changes?**
1. **Are there any compliance or audit considerations we should be aware of?**
1. **How will these changes affect our disaster recovery and business continuity plans?**

## **Third-Party Integrations**

1. **How do we coordinate with third-party vendors who use connected apps with our org?**
1. **What documentation should we request from integration partners?**
1. **Will managed packages be affected by these changes?**
1. **How do we handle connected apps used by consulting partners or contractors?**

## **Monitoring & Ongoing Management**

1. **What new monitoring capabilities are available for connected app usage?**
1. **How can we set up alerts for unauthorized connected app authorization attempts?**
1. **What’s the recommended governance process for connected apps going forward?**
1. **How frequently should we audit connected apps after these changes?**
1. **Are there any new best practices or security recommendations we should implement?**

## **Support & Resources**

1. **What additional training or resources are available for our admin team?**
1. **Is there dedicated support available during the transition period?**
1. **Where can we find updated documentation and implementation guides?**
1. **Are there any Salesforce events or webinars covering these changes in detail?**
1. **Who should be our primary point of contact for issues during the transition?**
1. **What’s the escalation path if we encounter critical issues after the changes take effect?**

-----

**Preparation Checklist Items to Discuss:**

- [ ] Complete connected apps audit by [specific date]
- [ ] Test alternative Data Loader authentication methods
- [ ] Update user permissions and security settings
- [ ] Coordinate with all integration partners
- [ ] Develop communication plan for end users
- [ ] Create rollback and contingency procedures