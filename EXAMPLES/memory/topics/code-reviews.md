# Code Reviews

Source: https://www.notion.so/3142739df2f2800ab614f246da21dbe1

> This template documents how to review code. Helpful for new and remote employees to get and stay aligned.

# Philosophy

Why do you perform code reviews? What are your guiding principles for these reviews?

You may want to mention other pages here. Like Engineering Guidelines. To link to another page inline, type `@` followed by the name of the page: [Engineering Guidelines](https://www.notion.so/3142739df2f280fba79be547a68e50b1)

# Preparing Code for Review

Preparation sets your reviewers up for success.

### Commit Messages

Make sure your commit messages are descriptive. 

### Github PR Descriptions

Your PR descriptions should be an extension of your commit messages. Write about both what the commit changes, and how you implemented the change. 

# Performing Code Reviews

### How to Review

- Make two passes over the PR if it's substantial. 

# Examples

```javascript
var commentCount = 0;
```

You might suggest that this be a `let` instead of `var`. 


