# movement-validator

This is a simple PoC validator for DOOM player movement. It is based on the [doom-wasm](https://github.com/ch1bo/doom-wasm/blob/7268cc11cf8d25c2ce4854282c5c8523faaf6228/src/doom/p_user.c#L141C6-L141C18) player movement logic.

## Building

```sh
aiken build
```

## Testing

You can write tests in any module using the `test` keyword. For example:

```gleam
test foo() {
  1 + 1 == 2
}
```

To run all tests, simply do:

```sh
aiken check
```

To run only tests matching the string `foo`, do:

```sh
aiken check -m foo
```

## Documentation

If you're writing a library, you might want to generate an HTML documentation for it.

Use:

```sh
aiken docs
```

## Resources

Find more on the [Aiken's user manual](https://aiken-lang.org).
