# Onibi

Onibi is an implementation of regular expression engine written in Ruby.

## Usage

```ruby
regexp = Onibi.new("namu(syaka)?")
regexp.match?("namusyaka") #=> true
regexp.match?("namu") #=> true
regexp.match?("namusya") #=> false
```

## Syntax

<table>
  <thead>
    <th>Syntax</th>
    <th>Description</th>
  </thead>
  <tbody>
    <tr>
      <td>*</td>
      <td>Matches the preceding element zero or more times.</td>
    </tr>
    <tr>
      <td>+</td>
      <td>Matches the preceding element one or more times.</td>
    </tr>
    <tr>
      <td>?</td>
      <td>Matches the preceding element zero or one time.</td>
    </tr>
    <tr>
      <td>()</td>
      <td>Defines a subexpr.</td>
    </tr>
    <tr>
      <td>[]</td>
      <td>The bracket expression.</td>
    </tr>
    <tr>
      <td>|</td>
      <td>The union operator matches either the expression before or the expression after the operator.</td>
    </tr>
  </tbody>
</table>

## Contributing

1. Fork it ( https://github.com/namusyaka/onibi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
